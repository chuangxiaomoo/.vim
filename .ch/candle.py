import time
import pandas   as pd
import tushare  as ts
from math import pi
from bokeh.layouts import gridplot, column
from bokeh.models import ColumnDataSource, HoverTool,CrosshairTool
from bokeh.plotting import figure, show, output_file
from bokeh.sampledata.stocks import MSFT, AAPL
from sys import exit

def fn_plot_vol(df, p_v):
    w = .72 # 10jqka = 9/11
    i_src = ColumnDataSource(df[df.open <  df.close])
    d_src = ColumnDataSource(df[df.open >= df.close])

    p_v.vbar('idt', w, top='vol', source=i_src, name="volumn", fill_color="red", fill_alpha=0, line_width=0.8, line_color="red" )
    p_v.vbar('idt', w, top='vol', source=d_src, name="volumn", fill_color="green",             line_width=0.8, line_color="green")

    #_v.toolbar.active_scroll = "auto"
    p_v.xaxis.major_label_orientation = pi/4
    p_v.grid.grid_line_alpha=0.1
    p_v.background_fill_color = "black"
    p_v.sizing_mode = 'stretch_both'

    hover_tool = p_v.add_tools(HoverTool(tooltips=[
                ("date","@ToolTipD"),
                ("vol" ,"@vol{0,0.00}"),
                ("diff","@diff{0,0.00}"),
                ("macd","@macd{0,0.00}"),
                ("dea","@dea{0,0.00}")], names= ["volumn","macd"], mode="mouse", point_policy="follow_mouse"))
    pass

def fn_ma(df, col, N):
    sum = 0
    for i in range(len(df)):
        if i>=20:
            sum -= df.get_value(i-20, 'close')
            sum += df.get_value(i, 'close')
            df.set_value(i, col, sum/20)
        elif i==19:
            sum += df.get_value(i, 'close')
            df.set_value(i, col, sum/20)
        else:
            sum += df.get_value(i, 'close')
    pass

def fn_plot_kline(df, p_k, all_source):
    w = .72 # 10jqka = 9/11
    i_src = ColumnDataSource(df[df.open <  df.close])
    d_src = ColumnDataSource(df[df.open >= df.close])

    #_k.toolbar.active_scroll = "auto"
    p_k.xaxis.major_label_orientation = pi/4
    p_k.grid.grid_line_alpha=0.1
    p_k.background_fill_color = "black"

    p_k.segment('idt', 'high', 'idt', 'low', source=i_src, name="kline", color="red", line_width=0.8)
    p_k.segment('idt', 'high', 'idt', 'low', source=d_src, name="kline", color="green", line_width=0.8)

    p_k.vbar('idt', w, 'open', 'close', source=i_src, name="kbar", fill_color="black", line_color="red", line_width=0.8)
    p_k.vbar('idt', w, 'open', 'close', source=d_src, name="kbar", fill_color="green", line_color="green", line_width=0.8)

    p_k.line('idt', 'ma20', source=all_source, name='ma20', line_color="purple")

    hover_tool = p_k.add_tools(HoverTool(tooltips= [
                ("date","@ToolTipD"),
                ("time","@ToolTipT"),
                ("close","@close{0,0.00}"),
                ("high","@high{0,0.00}"),
                ("low","@low{0,0.00}"),
                ("ma20","@ma20{0,0.00}"),
                ], names=["kline","kbar"], mode="mouse")) # vline doesn't work
    p_k.sizing_mode = 'stretch_both'

def fn_ema(df, src, dst, N):
    for i in range(len(df)):
        if i>0:
            df.set_value(i, dst, (2*df.get_value(i, src)+(N-1)*df.get_value(i-1,dst))/(N+1))
        else:
            df.set_value(i, dst, df.get_value(0, src))
    return df[dst]

def fn_plot_macd(df, p_m, all_source):
    w = .40 # 10jqka = 9/11
    i_macd = ColumnDataSource(df[df.macd >= 0])
    d_macd = ColumnDataSource(df[df.macd <  0])
    # plot
    #_m.toolbar.active_scroll = "auto"
    p_m.xaxis.major_label_orientation = pi/4
    p_m.grid.grid_line_alpha=0.1
    p_m.background_fill_color = "black"
    p_m.vbar('idt', w/10, top='macd', source=i_macd, name='macd', fill_color="red", line_color="red")
    p_m.vbar('idt', w/10, top=0, bottom='macd', source=d_macd, name='macd', fill_color="green", line_color="green")
    p_m.line('idt', 'diff', source=all_source, name='macd', line_color="white")
    p_m.line('idt', 'dea',  source=all_source, name='macd', line_color="yellow")
    pass

def fn_uni_process(df, asc, sta, end):
    asc_bi = asc
    hi = 0
    lo = 1

    k1 = [df.get_value(sta, 'high'), df.get_value(sta, 'low')]
    for i in range(sta+1, end-1):
        k2 = [df.get_value(i, 'high'), df.get_value(i, 'low')]
        # print(i, k1[hi] , k2[hi] , k1[lo] , k2[lo])
        if (k1[hi] >= k2[hi] and k1[lo] <= k2[lo]) or (k2[hi] >= k1[hi] and k2[lo] <= k1[lo]):
            if asc_bi:
                k1 = [max(k2[hi],k1[hi]), max(k1[lo], k2[lo])]
                df.set_value(i, 'uni', 1)                       # up
                # print('got i asc:', df.get_value(i, 'idt'), i)
            else:
                k1 = [min(k2[hi],k1[hi]), min(k1[lo], k2[lo])]
                df.set_value(i, 'uni', -1)                      # down
                # print('got i dsc:', df.get_value(i, 'idt'), i)
                pass
        elif k2[hi] > k1[hi]:                           # k2 新高
            asc_bi = True
            k1 = k2
        elif k2[lo] < k1[lo]:                           # k2 新低
            asc_bi = False
            k1 = k2

def fn_plot_fenbi(df, p_k, tbl_bi):
    df_len = len(df)
    df_fb = df[0:9]
    id_max_hi=df_fb.high.idxmax()
    id_min_lo=df_fb.low.idxmin()

    df['uni'] = [0 for i in range(len(df))]
    fn_uni_process(df, id_max_hi>id_min_lo, max(id_max_hi,id_min_lo), df_len)

    i_bi = 0
    asc = False
    # print(id_min_lo, id_max_hi)

    if id_max_hi - id_min_lo >= 4:
        tbl_bi.loc[i_bi] = [df.get_value(id_min_lo, 'idt'), df.get_value(id_min_lo, 'low')]
        i_bi+=1
        tbl_bi.loc[i_bi] = [df.get_value(id_max_hi, 'idt'), df.get_value(id_max_hi, 'high')]
        i_bi+=1
        asc = True
    elif  id_max_hi - id_min_lo <= -4:
        tbl_bi.loc[i_bi] = [df.get_value(id_max_hi, 'idt'), df.get_value(id_max_hi, 'high')]
        i_bi+=1
        tbl_bi.loc[i_bi] = [df.get_value(id_min_lo, 'idt'), df.get_value(id_min_lo, 'low')]
        i_bi+=1
        asc = False
    else:
        print('I am Retrying')
        pass

    id_max_hi0 = id_max_hi
    id_min_lo0 = id_min_lo
    asc0 = asc

    sta = 0
    end = 0
    offset = 0

    while sta < df_len-1 and end < df_len-1:
        sta = max(id_max_hi0, id_min_lo0)
        end = sta+offset+5<=df_len-1 and sta+offset+5 or df_len-1
        df_fb = df[sta:end]

        # print(sta, end, offset)       # useful info
        id_max_hi=df_fb.high.idxmax()
        id_min_lo=df_fb.low.idxmin()

        if asc0:
            if id_max_hi != id_max_hi0 and df.get_value(id_max_hi, 'high') > df.get_value(id_max_hi0, 'high'):   # 创新高
                tbl_bi.loc[i_bi-1] = [df.get_value(id_max_hi, 'idt'), df.get_value(id_max_hi, 'high')]
                id_max_hi0 = id_max_hi
                offset = 0
                continue

            # 形成底分型
            elif id_min_lo-id_max_hi>=4 and \
                    (id_min_lo-id_max_hi - len(df[(df.index>=id_max_hi) & (df.index<=id_min_lo) & (df.uni != 0)]) >= 4):
                tbl_bi.loc[i_bi] = [df.get_value(id_min_lo, 'idt'), df.get_value(id_min_lo, 'low')]
                i_bi+=1
                asc0 = False
                offset = 0
                id_min_lo0 = id_min_lo
                continue
            else:                                   #
                offset += 5
                pass
        elif not asc0:
            if id_min_lo != id_min_lo0 and df.get_value(id_min_lo, 'low') < df.get_value(id_min_lo0, 'low'):
                tbl_bi.loc[i_bi-1] = [df.get_value(id_min_lo, 'idt'), df.get_value(id_min_lo, 'low')]
                id_min_lo0 = id_min_lo
                offset = 0
                continue
            # 形成顶分型
            elif id_max_hi-id_min_lo>=4 and \
                    (id_max_hi-id_min_lo - len(df[(df.index>=id_min_lo) & (df.index<=id_max_hi) & (df.uni != 0)]) >= 4):
                tbl_bi.loc[i_bi] = [df.get_value(id_max_hi, 'idt'), df.get_value(id_max_hi, 'high')]
                i_bi+=1
                asc0 = True
                offset = 0
                id_max_hi0 = id_max_hi
                continue
            else:
                offset += 5
                pass

    p_k.line(tbl_bi.idt, tbl_bi.price, line_width=.8, color="#6abcff", line_alpha=1)
    p_k.triangle(df.idt[df.uni ==  1], df.high[df.uni ==  1]*1.03, size=5, color="red", alpha=0.5)
    p_k.triangle(df.idt[df.uni == -1], df.low [df.uni == -1]*0.97, size=5, color="green", alpha=0.5)
    print('_____')
    pass

def fn_plot_block(p_k, tbl_bi):
    # 因为 even 非中心对称，so use hbar but not rect
    i_zs = 0
    i = 0
    tbl_len = len(tbl_bi)
    tbl_zs = pd.DataFrame(columns=('sta', 'end', 'hig', 'low'))
                                      
    #                     7               /5           1     3
    #                    /           3   /            / \   / \
    #             5     /           / \ /            /   \ /   \
    #        3   / \   /           /   4            /     2     \
    #   1   / \ /   \ /       1   /                /             \   5
    #  / \ /   4     6       / \ /                /               \ / \
    # /   2                 /   2                0                 4   \
    # 0                     0                                           \

    # 0                     0                                           /
    # \   2                 \   2                0                 4   /
    #  \ / \   4     6       \ / \                \               / \ /
    #   1   \ / \   / \       1   \                \             /   5
    #        3   \ /   \           \   4            \     2     /     
    #             5     \           \ / \            \   / \   /       
    #                    \           3   \            \ /   \ /         
    #                     7               \5           1     3 

    biprice = tbl_bi.price
    bidate = tbl_bi.idt
    while i <= tbl_len-5:
        if biprice[i+1] > biprice[i+0]:
            if biprice[i+3] < biprice[i+0]:                                         # 同向两笔须交
                i = i+1
                continue

            if max(biprice[i+2], biprice[i+4]) > min(biprice[i+1], biprice[i+3]):   # 走势延升
                i = i+1
                continue

            sta = bidate[i+1]
            end = bidate[i+4]
            hig = min(biprice[i+1], biprice[i+3])
            low = max(biprice[i+2], biprice[i+4]) 
            print("___got zs @", sta, end, "hig & low: ", hig, low)

            i = i+4
            while i <= tbl_len-3:                                                    # 中枢扩展
                if min(hig, biprice[i+1]) > max(low, biprice[i+2]):
                    hig = min(biprice[i+1], hig)
                    low = max(biprice[i+2], low) 
                    end = bidate[i+2]
                    print("___got bridge @", end, "hig & low: ", hig, low)
                    i = i+2
                else:
                    print("___got gap    @", bidate[i+1], bidate[i+2], biprice[i+1], biprice[i+2])
                    break
            tbl_zs.loc[i_zs] = [sta, end, hig, low]
            i_zs = i_zs+1

            if i < tbl_len-1 and biprice[i+1] < low:                                # 中枢破坏
                i = i-1
                pass
        else:
            if biprice[i+3] > biprice[i+0]:                                         # 同向两笔须交.dsc
                i = i+1
                continue

            if min(biprice[i+2], biprice[i+4]) < max(biprice[i+1], biprice[i+3]):   # 走势延升.dsc
                i = i+1
                continue

            sta = bidate[i+1]
            end = bidate[i+4]
            hig = min(biprice[i+2], biprice[i+4]) 
            low = max(biprice[i+1], biprice[i+3])
            print("___got zs @", sta, end)

            i = i+4
            while i <= tbl_len-3:                                                    # 中枢扩展.dsc
                if min(hig, biprice[i+2]) > max(low, biprice[i+1]):
                    hig = min(biprice[i+2], hig)
                    low = max(biprice[i+1], low) 
                    end = bidate[i+2]
                    print("___got bridge @", end)
                    i = i+2
                else:
                    print("___got gap    @sta: ", bidate[i+1], bidate[i+2])
                    break
            tbl_zs.loc[i_zs] = [sta, end, hig, low]
            i_zs = i_zs+1

            if i < tbl_len-1 and biprice[i+1] > low:                                 # 中枢破坏.dsc
                i = i-1
                pass
    pass
    p_k.hbar((tbl_zs.hig+tbl_zs.low)/2, 
                tbl_zs.hig-tbl_zs.low,
                tbl_zs.sta,
                tbl_zs.end, 
                name="zs", line_color="white", fill_alpha = 0, line_width = 0.8)

#   p_k.hbar( (180+220)/2, 220-180,
#             pd.to_datetime('2007-12-05'), pd.to_datetime('2008-01-08'),
#              name="zs2", line_color="white", fill_alpha = 0, line_width = 0.8)

    pass

def fn_main():
    #df = pd.DataFrame(AAPL)[:2000]
    #print(df.head(3))
    #print("index is:", df.index)
    #print("columns is:", df.columns)
    #return

    cons = ts.get_apis()
   #df = ts.bar('399006', conn=cons, asset='INDEX', freq='D', start_date='2015-01-01', end_date='')
    df = ts.bar('399006', conn=cons, asset='INDEX', freq='D', start_date='2015-01-01', end_date='')

    print("______len:", len(df))
    #print(df)
    #return
    #df = ts.bar('600000', conn=cons, freq='D', start_date='2017-11-01', end_date='')
    #print("index is:", df.index)
    #print("columns is:", df.columns)
    #return

    df['ToolTipD'] = df.index.map(lambda x: x.strftime("%y-%m-%d"))
    df['ToolTipT'] = df.index.map(lambda x: x.strftime("%T"))
    df["idt"] = [i for i in range(len(df))]
    df.index = [i for i in range(len(df))]
    #df = df.reset_index(drop=True)

    TOOL_x = "xwheel_zoom"
    TOOL_k = "pan,xwheel_zoom,ywheel_zoom,box_zoom,reset"
    TOOL_v = "pan,ywheel_zoom"
    TOOL_m = "pan,ywheel_zoom"

    p_x = figure(x_axis_type="linear", tools=TOOL_x, plot_width=1504, plot_height= 12, active_scroll="xwheel_zoom")
    p_k = figure(x_axis_type="linear", tools=TOOL_k, plot_width=1504, plot_height=600, active_scroll="ywheel_zoom")
    p_v = figure(x_axis_type="linear", tools=TOOL_v, plot_width=1504, plot_height=152, active_scroll="ywheel_zoom")     # title="vol"
    p_m = figure(x_axis_type="linear", tools=TOOL_m, plot_width=1504, plot_height=180, active_scroll="ywheel_zoom")     # hei 880

    p_k.add_tools(CrosshairTool(line_color='#999999'))
    p_m.add_tools(CrosshairTool(line_color='#999999'))
    p_v.add_tools(CrosshairTool(line_color='#999999'))

    p_x.x_range = p_k.x_range = p_v.x_range = p_m.x_range         # 3 link must at one line
    p_x.xaxis.visible = p_k.xaxis.visible = p_v.yaxis.visible = p_v.xaxis.visible = False
    p_x.background_fill_color = "black"
    p_x.grid.grid_line_alpha=0.1
    p_x.line(df.idt, 0, line_color="white", line_width=.01)

    df['ma20'] = [0.0 for i in range(len(df))]
    fn_ma(df, 'ma20', 20)

    df['long'] = [0.0 for i in range(len(df))]
    df['short'] = [0.0 for i in range(len(df))]
    df['diff'] = fn_ema(df, 'close', 'short', 12) - fn_ema(df, 'close', 'long', 26)
    df['dea'] = fn_ema(df, 'diff', 'dea', 9)
    df['macd'] = 2*(df['diff']-df['dea'])

    all_source = ColumnDataSource(df)
    tbl_bi = pd.DataFrame(columns=('idt', 'price'))

    fn_plot_kline(df, p_k, all_source)
    fn_plot_fenbi(df, p_k, tbl_bi)
    fn_plot_block(p_k, tbl_bi)
    fn_plot_vol(df, p_v)
    fn_plot_macd(df, p_m, all_source)

    output_file("chan.html", title="chan", mode='inline')
    grid = gridplot([[p_x],[p_k], [p_v], [p_m]], merge_tools=False, responsive=True)
    grid.sizing_mode = 'stretch_both'
    show(grid)
    pass

t_sta = time.time()
fn_main()
print("Spend total:", time.time() - t_sta)
