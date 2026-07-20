/* hackOS :: dwm config.h — Super como MODKEY, tema oscuro/verde coherente */

static const unsigned int borderpx  = 2;
static const unsigned int snap      = 10;
static const int showbar            = 1;
static const int topbar             = 1;
static const char *fonts[]          = { "JetBrainsMono Nerd Font:size=10" };
static const char dmenufont[]       = "JetBrainsMono Nerd Font:size=10";

static const char col_bg[]       = "#0A0A0A";
static const char col_bg_alt[]   = "#141414";
static const char col_fg[]       = "#d6dbe0";
static const char col_fg_dim[]   = "#8a9099";
static const char col_accent[]   = "#EA0057";

static const char *colors[][3] = {
    /*               fg          bg         border   */
    [SchemeNorm] = { col_fg_dim, col_bg,    col_bg_alt },
    [SchemeSel]  = { col_bg,     col_accent, col_accent },
};

static const char *tags[] = { "1:Term", "2:Web", "3:Code", "4:Files", "5:Sys" };

static const Rule rules[] = {
    /* class      instance    title       tags mask     isfloating   monitor */
    { "librewolf", NULL,      NULL,       1 << 1,        0,           -1 },
    { "mullvad-browser", NULL, NULL,      1 << 1,        0,           -1 },
    { "Pluma",     NULL,      NULL,       1 << 2,        0,           -1 },
    { "Pcmanfm",   NULL,      NULL,       1 << 3,        0,           -1 },
    { "rofi",      NULL,      NULL,       0,             1,           -1 },
};

static const float mfact     = 0.55;
static const int nmaster     = 1;
static const int resizehints = 1;
static const int lockfullscreen = 1;

static const Layout layouts[] = {
    { "[]=",      tile },
    { "><>",      NULL },
    { "[M]",      monocle },
};

#define MODKEY Mod4Mask   /* tecla Super */
#define TAGKEYS(KEY,TAG) \
    { MODKEY,             KEY, view,      {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask, KEY, toggleview,{.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,   KEY, tag,       {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY, toggletag, {.ui = 1 << TAG} },

#define STACKKEYS(KEY,SKEY)

static char dmenumon[2] = "0";
static const char *dmenucmd[] = { "rofi", "-show", "run", NULL };
static const char *termcmd[]  = { "xterm", NULL };
static const char *filecmd[]  = { "pcmanfm", NULL };
static const char *lockcmd[]  = { "xtrlock", NULL };
static const char *browsercmd[] = { "librewolf", NULL };
static const char *editorcmd[] = { "pluma", NULL };

static const Key keys[] = {
    /* modifier                     key        function        argument */
    { MODKEY,                       XK_t,      spawn,          {.v = termcmd } },
    { MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
    { MODKEY,                       XK_e,      spawn,          {.v = filecmd } },
    { MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
    { MODKEY,                       XK_w,      spawn,          {.v = browsercmd } },
    { MODKEY,                       XK_c,      spawn,          {.v = editorcmd } },
    { MODKEY|ShiftMask,             XK_l,      spawn,          {.v = lockcmd } },
    { MODKEY,                       XK_b,      togglebar,      {0} },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
    { MODKEY,                       XK_u,      incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
    { MODKEY,                       XK_Return, zoom,           {0} },
    { MODKEY,                       XK_Tab,    view,           {0} },
    { MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
    { MODKEY,                       XK_space,  setlayout,      {0} },
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
    { MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
    { MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
    { MODKEY,                       XK_period, focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)
    TAGKEYS(                        XK_5,                      4)
    { MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

static const Button buttons[] = {
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
    { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
