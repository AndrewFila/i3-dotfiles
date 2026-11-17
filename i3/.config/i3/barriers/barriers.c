/*
 * barriers - invisible walls that keep the mouse out of dead screen space
 *
 * X treats all monitors as one big rectangle. With monitors of different
 * sizes, parts of that rectangle belong to no monitor, and with the NVIDIA
 * driver the cursor can wander into them. This puts an XFixes pointer barrier
 * on every monitor edge that does NOT touch another monitor, so the cursor
 * stops at the visible edge but still moves freely between monitors.
 *
 * It stays running (barriers vanish when the program exits) and rebuilds the
 * walls whenever the monitor layout changes.
 *
 * usage: barriers        run (normally started by i3)
 *        barriers -n     print the walls it would create, then exit
 *
 * build: cc -O2 -o barriers barriers.c -lX11 -lXfixes -lXrandr
 */
#include <X11/Xlib.h>
#include <X11/extensions/Xfixes.h>
#include <X11/extensions/Xrandr.h>
#include <stdio.h>
#include <string.h>

#define MAX_BARRIERS 256
#define MAX_SEGS 64

typedef struct { int lo, hi; } Seg;

static PointerBarrier barriers[MAX_BARRIERS];
static int nbarriers;
static int dry_run;

/* Remove [a, b) from a list of segments; returns the new count */
static int subtract(Seg *s, int n, int a, int b)
{
    Seg out[MAX_SEGS];
    int m = 0;
    for (int i = 0; i < n && m < MAX_SEGS - 1; i++) {
        if (b <= s[i].lo || a >= s[i].hi) {
            out[m++] = s[i];
            continue;
        }
        if (a > s[i].lo) out[m++] = (Seg){s[i].lo, a};
        if (b < s[i].hi) out[m++] = (Seg){b, s[i].hi};
    }
    memcpy(s, out, m * sizeof *s);
    return m;
}

static void add_barrier(Display *dpy, Window root, int x1, int y1, int x2, int y2,
                        int dirs, const char *what)
{
    if (dry_run) {
        printf("wall %-6s (%d,%d) -> (%d,%d)\n", what, x1, y1, x2, y2);
        return;
    }
    if (nbarriers < MAX_BARRIERS)
        barriers[nbarriers++] =
            XFixesCreatePointerBarrier(dpy, root, x1, y1, x2, y2, dirs, 0, NULL);
}

static void build(Display *dpy, Window root)
{
    for (int i = 0; i < nbarriers; i++)
        XFixesDestroyPointerBarrier(dpy, barriers[i]);
    nbarriers = 0;

    int n;
    XRRMonitorInfo *mon = XRRGetMonitors(dpy, root, True, &n);
    if (!mon) return;

    for (int i = 0; i < n; i++) {
        int x = mon[i].x, y = mon[i].y, w = mon[i].width, h = mon[i].height;

        /* side: 0 top, 1 bottom, 2 left, 3 right */
        for (int side = 0; side < 4; side++) {
            int horiz = side < 2;
            int c = side == 0 ? y : side == 1 ? y + h : side == 2 ? x : x + w;
            Seg segs[MAX_SEGS] = {{horiz ? x : y, horiz ? x + w : y + h}};
            int ns = 1;

            /* cut out the parts of this edge that touch another monitor */
            for (int j = 0; j < n; j++) {
                if (j == i) continue;
                int ox = mon[j].x, oy = mon[j].y, ow = mon[j].width, oh = mon[j].height;
                int touches = side == 0 ? oy + oh == c
                            : side == 1 ? oy == c
                            : side == 2 ? ox + ow == c
                            :             ox == c;
                if (touches)
                    ns = horiz ? subtract(segs, ns, ox, ox + ow)
                               : subtract(segs, ns, oy, oy + oh);
            }

            /* the wall lets the cursor move inward only */
            static const int dirs[4] = {BarrierPositiveY, BarrierNegativeY,
                                        BarrierPositiveX, BarrierNegativeX};
            static const char *names[4] = {"top", "bottom", "left", "right"};
            for (int k = 0; k < ns; k++) {
                if (horiz)
                    add_barrier(dpy, root, segs[k].lo, c, segs[k].hi, c, dirs[side], names[side]);
                else
                    add_barrier(dpy, root, c, segs[k].lo, c, segs[k].hi, dirs[side], names[side]);
            }
        }
    }
    XRRFreeMonitors(mon);
    XFlush(dpy);
}

int main(int argc, char **argv)
{
    dry_run = argc > 1 && strcmp(argv[1], "-n") == 0;

    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "barriers: cannot open display\n");
        return 1;
    }
    Window root = DefaultRootWindow(dpy);

    int fx_ev, fx_err, major = 5, minor = 0;
    if (!XFixesQueryExtension(dpy, &fx_ev, &fx_err) ||
        !XFixesQueryVersion(dpy, &major, &minor) || major < 5) {
        fprintf(stderr, "barriers: XFixes 5 (pointer barriers) not available\n");
        return 1;
    }
    int rr_ev, rr_err;
    if (!XRRQueryExtension(dpy, &rr_ev, &rr_err)) {
        fprintf(stderr, "barriers: RandR not available\n");
        return 1;
    }

    build(dpy, root);
    if (dry_run) return 0;

    XRRSelectInput(dpy, root, RRScreenChangeNotifyMask);
    for (;;) {
        XEvent ev;
        XNextEvent(dpy, &ev);
        if (ev.type == rr_ev + RRScreenChangeNotify) {
            XRRUpdateConfiguration(&ev);
            build(dpy, root);
        }
    }
}
