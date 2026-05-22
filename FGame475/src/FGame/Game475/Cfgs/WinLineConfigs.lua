local cfg = {}
cfg.Lines = {
    { line = { 1, 1, 1, 1, 1, }, color = "#00ACEE" }, -- 1
    { line = { 0, 0, 0, 0, 0, }, color = "#ED008A" }, -- 2
    { line = { 2, 2, 2, 2, 2, }, color = "#EA1C24" }, -- 3
    { line = { 0, 1, 2, 1, 0, }, color = "#00A550" }, -- 4
    { line = { 2, 1, 0, 1, 2, }, color = "#303093" }, -- 5
    { line = { 0, 0, 1, 0, 0, }, color = "#A56B08" }, -- 6
    { line = { 2, 2, 1, 2, 2, }, color = "#F5921F" }, -- 7
    { line = { 1, 2, 2, 2, 1, }, color = "#008FD1" }, -- 8
    { line = { 1, 0, 0, 0, 1, }, color = "#5C1254" }, -- 9
    { line = { 0, 1, 1, 1, 0, }, color = "#8BC541" }, -- 10
    { line = { 2, 1, 1, 1, 2, }, color = "#BE198D" }, -- 11
    { line = { 0, 1, 0, 1, 0, }, color = "#00A3BB" }, -- 12
    { line = { 2, 1, 2, 1, 2, }, color = "#F06422" }, -- 13
    { line = { 1, 0, 1, 0, 1, }, color = "#0071BB" }, -- 14
    { line = { 1, 2, 1, 2, 1, }, color = "#F7947B" }, -- 15
    { line = { 1, 1, 0, 1, 1, }, color = "#E90A6D" }, -- 16
    { line = { 1, 1, 2, 1, 1, }, color = "#672D90" }, -- 17
    { line = { 0, 2, 0, 2, 0, }, color = "#E91A3B" }, -- 18
    { line = { 2, 0, 2, 0, 2, }, color = "#008A82" }, -- 19
    { line = { 1, 0, 2, 0, 1, }, color = "#C9DA2C" }, -- 20
    { line = { 1, 2, 0, 2, 1, }, color = "#F5E500" }, -- 21
    { line = { 0, 0, 2, 0, 0, }, color = "#F8A1A4" }, -- 22
    { line = { 2, 2, 0, 2, 2, }, color = "#E21355" }, -- 23
    { line = { 0, 2, 2, 2, 0, }, color = "#0053A5" }, -- 24
    { line = { 2, 0, 0, 0, 2, }, color = "#D15EA0" }, -- 25
    { line = { 0, 2, 1, 2, 0, }, color = "#00ACEE" }, -- 26
    { line = { 2, 0, 1, 0, 2, }, color = "#ED008A" }, -- 27
    { line = { 1, 1, 1, 1, 2, }, color = "#EA1C24" }, -- 28
    { line = { 0, 0, 1, 2, 2, }, color = "#00A550" }, -- 29
    { line = { 2, 2, 1, 0, 0, }, color = "#303093" }, -- 30
    { line = { 0, 1, 1, 1, 2, }, color = "#FFC20D" }, -- 31
    { line = { 2, 1, 1, 1, 0, }, color = "#F5921F" }, -- 32
    { line = { 0, 1, 2, 1, 2, }, color = "#008FD1" }, -- 33
    { line = { 2, 1, 0, 1, 0, }, color = "#8D278D" }, -- 34
    { line = { 0, 0, 0, 0, 1, }, color = "#8BC541" }, -- 35
    { line = { 2, 2, 2, 2, 1, }, color = "#BE198D" }, -- 36
    { line = { 0, 1, 0, 1, 2, }, color = "#02A7BF" }, -- 37
    { line = { 2, 1, 2, 1, 0, }, color = "#F06422" }, -- 38
    { line = { 1, 0, 1, 2, 1, }, color = "#0071BB" }, -- 39
    { line = { 1, 2, 1, 0, 1, }, color = "#F6937B" }, -- 40
    { line = { 1, 1, 0, 0, 0, }, color = "#EF0873" }, -- 41
    { line = { 1, 1, 2, 2, 2, }, color = "#662C8F" }, -- 42
    { line = { 1, 0, 0, 1, 2, }, color = "#E51740" }, -- 43
    { line = { 1, 2, 2, 1, 0, }, color = "#00A898" }, -- 44
    { line = { 1, 0, 1, 2, 2, }, color = "#C9DA2C" }, -- 45
    { line = { 1, 2, 1, 0, 0, }, color = "#FFF102" }, -- 46
    { line = { 2, 1, 0, 0, 1, }, color = "#37B348" }, -- 47
    { line = { 0, 1, 2, 2, 1, }, color = "#EA1456" }, -- 48
    { line = { 0, 0, 1, 2, 1, }, color = "#0053A5" }, -- 49
    { line = { 2, 2, 1, 0, 1, }, color = "#D562A4" }, -- 50
}

cfg.Type2Url = {
    [0] = "ui://Basics/slots_line_flat",
    [1] = "ui://Basics/slots_line_short_down",
    [2] = "ui://Basics/slots_line_long_down",
    [-1] = "ui://Basics/slots_line_short_up",
    [-2] = "ui://Basics/slots_line_long_up",
}

return cfg
