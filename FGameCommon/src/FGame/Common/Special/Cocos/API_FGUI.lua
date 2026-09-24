FairyGUI.InputEvent = 
{
    -- variables
    x, -- get
    y, -- get
    touchId, -- get
    button, -- get
    isDoubleClick, -- get
    ctrl, -- get
    shift, -- get
    alt, -- get
    keyCode, -- get
    mouseWheelDelta, -- get
    position, -- get

    -- functions
    GetProcessor = function() end,-- (Unity没有的API)
    GetTouch = function() end,-- (Unity没有的API)
    GetTarget = function() end,-- (Unity没有的API)
}

FairyGUI.EventContext = 
{
    -- variables
    isDefaultPrevented, -- get
    type, -- get
    sender, -- get
    inputEvent, -- get
    data, -- get

    -- functions
    PreventDefault = function() end,
    CaptureTouch = function() end,
    UncaptureTouch = function() end,-- (Unity没有的API)
    StopPropagation = function() end,
    GetDataValue = function() end,-- (Unity没有的API)
}

-- Unity->EventDispatcher
FairyGUI.UIEventDispatcher = 
{
    -- variables

    -- functions
    isDispatching = function() end,
    RemoveEventListeners = function() end,
    DispatchEvent = function() end,
    BubbleEvent = function() end,
    AddEventListener = function() end,
    RemoveEventListener = function() end,
    hasEventListeners = function() end,
}

-- Unity->Controller
FairyGUI.GController = 
{
    -- variables
    previsousIndex, -- get
    selectedPageId, -- get/set
    parent, -- get/set
    oppositePageId, -- set
    pageCount, -- get
    selectedIndex, -- get/set
    previousPage, -- get
    previousPageId, -- get
    selectedPage, -- get/set

    -- functions
    SetSelectedPageId = function() end,
    SetSelectedPage = function() end,
    GetPageIndexById = function() end,
    GetPageId = function() end,
    RunActions = function() end,
    HasPage = function() end,
    GetPageNameById = function() end,
    SetSelectedIndex = function() end,
}

---@class FairyGUI.GObject
FairyGUI.GObject = 
{
    -- variables
    id, -- get
    name, -- get/set
    sourceWidth, -- get
    sourceHeight, -- get
    initWidth, -- get
    initHeight, -- get
    minWidth, -- get
    minHeight, -- get
    maxWidth, -- get
    maxHeight, -- get
    group, -- get/set
    xMin, -- get/set
    yMin, -- get/set
    scaleX, -- get/set
    scaleY, -- get/set
    scale, -- get/set
    pivotAsAnchor, -- get/set
    draggable, -- get/set
    touchable, -- get/set
    userData, -- get/set (unity没有的API)
    rotation, -- get/set
    x, -- get/set
    y, -- get/set
    xy, -- get/set (type:vec2)
    pivot, -- get/set
    position, -- get/set (type:vec3)
    width, -- get/set
    height, -- get/set
    size, -- get/set
    alpha, -- get/set
    skew, -- get/set
    text, -- get/set
    grayed, -- get/set
    root, -- get
    icon, -- get/set
    resourceURL, -- get
    tooltips, -- get/set
    pixelSnapping, -- get/set
    relations, -- get
    packageItem, -- get
    displayObject, -- get
    sortingOrder, -- get/set
    dragBounds, -- get/set
    onStage, -- get
    parent, -- get
    visible, -- get/set
    draggingObject, -- get
    data, -- get/set (unity中的data)
    enabled, -- get/set

    -- functions
    SetSize = function() end,
    SetPivot = function() end,
    SetScale = function() end,
    SetPosition = function() end,-- (unity是三个参数obj:SetPosition(0,1,2))
    GetProp = function() end,-- (unity没有的API)
    SetProp = function() end,-- (unity没有的API)
    TreeNode = function() end,-- (unity没有的API)
    HitTest = function() end,-- (unity没有的API)
    StartDrag = function() end,
    StopDrag = function() end,
    LocalToGlobal = function() end,
    LocalToRoot = function() end,-- (cocos中底层还是调用的LocalToGlobal函数)
    GlobalToLocal = function() end,
    RootToLocal = function() end,-- (cocos中底层还是调用的GlobalToLocal函数)
    GetGear = function() end,
    RemoveFromParent = function() end,-- (确保不在使用，要销毁此对象就传入参数true)
    ConstructFromResource = function() end,
    AddDisplayLock = function() end,
    RemoveRelation = function() end,
    ReleaseDisplayLock = function() end,
    MakeFullScreen = function() end,
    TransformRect = function() end,
    Center = function() end,
    AddRelation = function() end,
    CheckGearController = function() end,
    __call = function() end,
}

FairyGUI.UIPackage = 
{
    -- variables
    id, -- get
    name, -- get
    branch, -- get/set

    -- functions
    GetItemByName = function() end,
    GetItem = function() end,
    GetItems = function() end,
    CreateObjectFromURL = function() end,
    RemovePackage = function() end,
    GetItemURL = function() end,
    NormalizeURL = function() end,
    RemoveAllPackages = function() end,
    CreateObject = function() end,
    GetByName = function() end,
    AddPackage = function() end,
    GetById = function() end,
    GetItemByURL = function() end,
    GetEmptyTexture = function() end,-- (Unity没有的API)
}

FairyGUI.GImage = 
{
    -- variables
    color, -- get/set
    flip, -- get/set
    fillMethod, -- get/set
    fillOrigin, -- get/set
    fillClockwise, -- get/set
    fillAmount, -- get/set

    -- functions
    __call = function() end,
}

FairyGUI.GMovieClip = 
{
    -- variables
    frame, -- get/set
    color, -- get/set
    flip, -- get/set
    playing, -- get/set
    timeScale, -- get/set

    -- functions
    SetPlaySettings = function() end,
    Reverse = function() end,
    Advance = function() end,
    __call = function() end,
}

FairyGUI.ActionMovieClip = 
{
    -- variables
    frame, -- get/set
    timeScale, -- get/set

    -- functions
    SetPlaySettings = function() end,
    Advance = function() end,
}

FairyGUI.GTextField = 
{
    -- variables
    autoSize, -- get/set
    fontSize, -- get/set (Unity没有的API)
    color, -- get/set
    singleLine, -- get/set
    UBBEnabled, -- get/set
    textFormat, -- get/set (set和unity不同)
    templateVars, -- get/set
    textWidth, -- get
    textHeight, -- get

    -- functions
    GetTextSize = function() end,-- (Unity没有的API,使用textWidthtextHeight)
    GetOutlineColor = function() end,-- (Unity没有的API)
    SetOutlineColor = function() end,-- (Unity没有的API)
    SetVar = function() end,
    FlushVars = function() end,
}

FairyGUI.GRichTextField = 
{
    -- variables

    -- functions
    GetControl = function() end,-- (Unity没有的API)
    GetControls = function() end,-- (Unity没有的API)
    __call = function() end,
}

FairyGUI.GTextInput = 
{
    -- variables
    keyboardType, -- set
    promptText, -- set
    maxLength, -- set
    restrict, -- set
    displayAsPassword, -- set

    -- functions
    __call = function() end,
}

FairyGUI.GGraph = 
{
    -- variables
    color, -- get/set

    -- functions
    SetPolygonPoints = function() end,-- (Unity没有的API)
    DrawPolygon = function() end,
    DrawRegularPolygon = function() end,-- (Unity没有的API)
    DrawEllipse = function() end,
    IsEmpty = function() end,-- (Unity没有的API)
    DrawRect = function() end,
    __call = function() end,
}

FairyGUI.GLoader = 
{
    -- variables
    url, -- get/set
    playing, -- get/set
    color, -- get/set
    align, -- get/set
    frame, -- get/set
    fill, -- get/set
    autoSize, -- get/set
    verticalAlign, -- get/set
    shrinkOnly, -- get/set
    fillMethod, -- get/set
    fillOrigin, -- get/set
    fillClockwise, -- get/set
    fillAmount, -- get/set
    component, -- get
    movieClip, -- get
    sprite, -- get (Unity没有的API)
    contentSize, -- get (Unity没有的API)

    -- functions
    __call = function() end,
}

---@class FairyGUI.GLoader3D
FairyGUI.GLoader3D = 
{
    -- variables
    url, -- get/set
    align, -- get/set
    verticalAlign, -- get/set
    autoSize, -- get/set
    fill, -- get/set
    shrinkOnly, -- get/set
    content, -- get/set
    color, -- get/set
    playing, -- get/set
    frame, -- get/set
    animationName, -- get/set
    skinName, -- get/set
    loop, -- get/set
    forceReplaySpine, -- get/set
    spineAnimation, -- get

    -- functions
    __call = function() end,
}

---@class FairyGUI.GGroup
FairyGUI.GGroup = 
{
    -- variables
    columnGap, -- get/set
    layout, -- get/set
    lineGap, -- get/set
    excludeInvisibles, -- get/set
    autoSizeDisabled, -- get/set
    mainGridIndex, -- get/set
    mainGridMinSize, -- get/set

    -- functions
    ResizeChildren = function() end,
    SetBoundsChangedFlag = function() end,
    MoveChildren = function() end,
    __call = function() end,
}

---@class FairyGUI.Transition
FairyGUI.Transition = 
{
    -- variables
    timeScale, -- get/set
    playing, -- get

    -- functions
    SetValue = function() end,
    ChangePlayTimes = function() end,
    OnOwnerRemovedFromStage = function() end,
    SetTarget = function() end,
    ClearHooks = function() end,
    Stop = function() end,
    GetOwner = function() end,-- (Unity没有的API)
    SetHook = function() end,
    SetDuration = function() end,
    SetAutoPlay = function() end,
    UpdateFromRelations = function() end,
    PlayReverse = function() end,
    Play = function() end,
}

---@class FairyGUI.ScrollPane
FairyGUI.ScrollPane = 
{
    -- variables
    bouncebackEffect, -- get/set
    hzScrollBar, -- get
    vtScrollBar, -- get
    decelerationRate, -- get/set
    percX, -- get/set
    percY, -- get/set
    posX, -- get/set
    posY, -- get/set
    currentPageX, -- get/set
    currentPageY, -- get/set
    footer, -- get
    header, -- get
    snapToItem, -- get/set
    touchEffect, -- get/set
    scrollStep, -- get/set
    scrollingPosX, -- get
    scrollingPosY, -- get
    isRightMost, -- get
    pageController, -- get/set
    inertiaDisabled, -- get/set
    mouseWheelEnabled, -- get/set
    owner, -- get
    isBottomMost, -- get
    draggingPane, -- get
    contentWidth, -- get
    contentHeight, -- get
    viewWidth, -- get
    viewHeight, -- get
    pageMode, -- get/set

    -- functions
    SetPercX = function() end,
    SetPercY = function() end,
    SetPosY = function() end,
    SetPosX = function() end,
    SetCurrentPageX = function() end,
    SetCurrentPageY = function() end,
    ScrollToView = function() end,
    ScrollTop = function() end,
    ScrollBottom = function() end,
    ScrollDown = function() end,
    ScrollRight = function() end,
    ScrollLeft = function() end,
    ScrollUp = function() end,
    IsChildInView = function() end,
    LockHeader = function() end,
    LockFooter = function() end,
    CancelDragging = function() end,
}

---@class FairyGUI.GComponent : FairyGUI.GObject
FairyGUI.GComponent = 
{
    -- variables
    opaque, -- get/set
    childrenRenderOrder, -- get/set
    viewWidth, -- get/set
    viewHeight, -- get/set
    mask, -- get/set
    apexIndex, -- get/set
    Controllers, -- get
    margin, -- get/set
    numChildren, -- get
    scrollPane, -- get

    -- functions
    GetHitArea = function() end,-- (unity没有的API)
    SetHitArea = function() end,-- (unity没有的API)
    GetTransitions = function() end,
    GetTransition = function() end,
    AddChild = function() end,
    ApplyAllControllers = function() end,
    EnsureBoundsCorrect = function() end,
    IsAncestorOf = function() end,
    GetChildren = function() end,
    AdjustRadioGroupDepth = function() end,
    GetController = function() end,
    GetFirstChildInView = function() end,
    IsChildInView = function() end,
    SetBoundsChangedFlag = function() end,
    AddChildAt = function() end,
    RemoveChildren = function() end,
    RemoveChildAt = function() end,
    ---@return FairyGUI.GObject
    GetChild = function() end,
    AddController = function() end,
    ChildSortingOrderChanged = function() end,
    ApplyController = function() end,
    SetChildIndex = function() end,
    GetChildById = function() end,
    GetChildByPath = function() end,
    GetChildIndex = function() end,
    GetControllerAt = function() end,
    GetChildAt = function() end,
    GetTransitionAt = function() end,
    GetChildInGroup = function() end,
    RemoveController = function() end,
    GetSnappingPosition = function() end,
    SetChildIndexBefore = function() end,
    SwapChildrenAt = function() end,
    RemoveChild = function() end,
    SwapChildren = function() end,
    ChildStateChanged = function() end,
    SetupOverflowHidden = function() end,
    IsOverflowHidden = function() end,
    __call = function() end,
}
---@class FairyGUI.GButton
FairyGUI.GButton = 
{
    -- variables
    relatedController, -- get/set
    changeStateOnClick, -- get/set
    selectedTitle, -- get/set
    selected, -- get/set
    title, -- get/set
    titleFontSize, -- get/set
    selectedIcon, -- get/set
    titleColor, -- get/set

    -- functions
    __call = function() end,
}

FairyGUI.GObjectPool = 
{
    -- variables

    -- functions
    GetObject = function() end,
    ReturnObject = function() end,
    Clear = function() end,
}

FairyGUI.GList = 
{
    -- variables
    itemRenderer, -- get/set
    itemProvider, -- get/set
    scrollItemToViewOnClick, -- get/set
    foldInvisibleItems, -- get/set
    columnGap, -- get/set
    lineCount, -- get/set
    layout, -- get/set
    columnCount, -- get/set
    numItems, -- get/set
    verticalAlign, -- get/set
    selectionController, -- get/set
    autoResizeItem, -- get/set
    isVirtual, -- get
    align, -- get/set
    selectedIndex, -- get/set
    selectionMode, -- get/set
    itemPool, -- get
    lineGap, -- get/set
    defaultItem, -- get/set

    -- functions
    SelectAll = function() end,
    SetVirtualAndLoop = function() end,
    RefreshVirtualList = function() end,
    RemoveSelection = function() end,
    SetVirtual = function() end,
    ResizeToFit = function() end,
    ReturnToPool = function() end,
    ClearSelection = function() end,
    RemoveChildToPoolAt = function() end,
    AddItemFromPool = function() end,
    SelectReverse = function() end,
    RemoveChildrenToPool = function() end,
    GetSelection = function() end,
    ItemIndexToChildIndex = function() end,
    ScrollToView = function() end,
    HandleArrowKey = function() end,
    GetFromPool = function() end,
    AddSelection = function() end,
    ChildIndexToItemIndex = function() end,
    RemoveChildToPool = function() end,
    __call = function() end,
}

FairyGUI.GComboBox = 
{
    -- variables
    values, -- get/set
    items, -- get/set
    icons, -- get/set
    title, -- get/set
    selectedIndex, -- get/set
    selectionController, -- get/set
    value, -- get/set

    -- functions
    Refresh = function() end,-- (Unity没有的API)
    __call = function() end,
}

FairyGUI.GProgressBar = 
{
    -- variables
    titleType, -- get/set
    max, -- get/set
    value, -- get/set
    min, -- get/set

    -- functions
    TweenValue = function() end,
    __call = function() end,
}

FairyGUI.GSlider = 
{
    -- variables
    changeOnClick, -- get/set
    canDrag, -- get/set
    titleType, -- get/set
    max, -- get/set
    value, -- get/set
    min, -- get/set
    wholeNumbers, -- get/set

    -- functions
    __call = function() end,
}

FairyGUI.GScrollBar = 
{
    -- variables
    minSize, -- get
    displayPerc, -- set
    scrollPerc, -- set

    -- functions
    SetScrollPane = function() end,
    __call = function() end,
}

FairyGUI.Window = 
{
    -- variables
    closeButton, -- get/set
    contentPane, -- get/set
    isTop, -- get
    frame, -- get
    isShowing, -- get
    contentArea, -- get/set
    bringToFontOnClick, -- get/set
    modal, -- get/set
    dragArea, -- get/set
    modalWaitingPane, -- get
    enableCustomAnimation, -- get/set

    -- functions
    Show = function() end,
    HideImmediately = function() end,
    ToggleStatus = function() end,
    Hide = function() end,
    CloseModalWait = function() end,
    Init = function() end,
    BringToFront = function() end,
    ShowModalWait = function() end,
    AddUISource = function() end,
    __call = function() end,
}

FairyGUI.GRoot = 
{
    -- variables
    inst, -- get
    touchTarget, -- get
    modalLayer, -- get
    hasModalWindow, -- get
    modalWaiting, -- get

    -- functions
    CloseAllWindows = function() end,
    HideTooltips = function() end,
    HasAnyPopup = function() end,
    GetTopWindow = function() end,
    HidePopup = function() end,
    CloseAllExceptModals = function() end,
    ShowPopup = function() end,
    ShowTooltipsWin = function() end,
    CloseModalWait = function() end,
    GetInputProcessor = function() end,-- (Unity没有的API)
    GetSoundVolumeScale = function() end,-- (Unity没有的API)
    TogglePopup = function() end,
    IsSoundEnabled = function() end,-- (Unity没有的API)
    SetSoundVolumeScale = function() end,-- (Unity没有的API)
    HideWindowImmediately = function() end,
    PlaySound = function() end,-- (Unity没有的API)
    GetModalWaitingPane = function() end,-- (Unity没有的API)
    SetSoundEnabled = function() end,-- (Unity没有的API)
    BringToFront = function() end,
    ShowModalWait = function() end,
    GetTouchPosition = function() end,-- ()
    GetPoupPosition = function() end,
    ShowWindow = function() end,
    ShowTooltips = function() end,
    HideWindow = function() end,
    __call = function() end,
}

FairyGUI.PopupMenu = 
{
    -- variables
    list, -- get
    contentPane, -- get
    itemCount, -- get

    -- functions
    SetItemGrayed = function() end,
    GetItemName = function() end,
    ClearItems = function() end,
    RemoveItem = function() end,
    AddItem = function() end,
    AddSeperator = function() end,
    AddItemAt = function() end,
    SetItemText = function() end,
    SetItemChecked = function() end,
    Show = function() end,
    SetItemCheckable = function() end,
    IsItemChecked = function() end,
    SetItemVisible = function() end,
    __call = function() end,
}

FairyGUI.UIObjectFactory = 
{
    -- variables

    -- functions
    NewObject = function() end,
    SetPackageItemExtension = function() end,
    SetLoaderExtension = function() end,
}

FairyGUI.DragDropManager = 
{
    -- variables
    dragging, -- get
    dragAgent, -- get
    inst, -- get

    -- functions
    Cancel = function() end,
    StartDrag = function() end,
    GetInstance = function() end,-- (Unity没有的API)
    DestroyInstance = function() end,-- (Unity没有的API)
}

FairyGUI.UIConfig = 
{
    -- variables
    defaultFont, -- set
    buttonSound, -- set
    buttonSoundVolumeScale, -- set
    defaultScrollStep, -- set
    defaultScrollDecelerationRate, -- set
    defaultScrollTouchEffect, -- set
    defaultScrollBounceEffect, -- set
    defaultScrollBarDisplay, -- set
    verticalScrollBar, -- set
    horizontalScrollBar, -- set
    touchDragSensitivity, -- set
    clickDragSensitivity, -- set
    touchScrollSensitivity, -- set
    defaultComboBoxVisibleItemCount, -- set
    globalModalWaiting, -- set
    modalLayerColor, -- set
    tooltipsWin, -- set
    bringWindowToFrontOnClick, -- set
    useEngineTextureCache, -- set
    useSkeletonCache, -- set
    windowModalWaiting, -- set
    popupMenu, -- set
    popupMenu_seperator, -- set
    onMusicCallback, -- set

    -- functions
    RegisterFont = function() end,
}

FairyGUI.GTween = 
{
    -- variables

    -- functions
    To = function() end,
    ToDouble = function() end,
    DelayedCall = function() end,
    Shake = function() end,
    IsTweening = function() end,
    Kill = function() end,
    GetTween = function() end,
    Clean = function() end,
}

FairyGUI.GCache = 
{
    -- variables

    -- functions
    GetInstance = function() end,
    Destroy = function() end,
    PreloadSkeletonData = function() end,
    ClearSkeletonData = function() end,
}

FairyGUI.GTweener = 
{
    -- variables
    delay, -- get
    duration, -- get
    target, -- get
    userData, -- get
    normalizedTime, -- get
    completed, -- get
    allCompleted, -- get
    startValue, -- get
    endValue, -- get
    value, -- get
    deltaValue, -- get

    -- functions
    SetDelay = function() end,
    SetDuration = function() end,
    SetBreakpoint = function() end,
    SetEase = function() end,
    SetEasePeriod = function() end,
    SetEaseOvershootOrAmplitude = function() end,
    GetRepeat = function() end,
    SetRepeat = function() end,
    SetTimeScale = function() end,
    SetSnapping = function() end,
    SetTarget = function() end,
    SetUserData = function() end,
    SetPath = function() end,
    SetPaused = function() end,
    Seek = function() end,
    Kill = function() end,
    OnUpdate = function() end,
    OnStart = function() end,
    OnComplete = function() end,
    OnComplete1 = function() end,
}

FairyGUI.TweenValue = 
{
    -- variables
    x, -- get/set
    y, -- get/set
    z, -- get/set
    w, -- get/set
    d, -- get/set
    vec2, -- get/set
    vec3, -- get/set
    vec4, -- get/set
    color, -- get/set

    -- functions
    SetZero = function() end,
}

FairyGUI.GLabel = 
{
    -- variables
    title, -- get/set
    titleColor, -- get/set
    titleFontSize, -- get/set

    -- functions
    GetTextField = function() end,
    __call = function() end,
}

-- Unity没有的API
FairyGUI.FUIInput = 
{
    -- variables
    displayAsPassword, -- get/set
    singleLine, -- get/set
    textFormat, -- get

    -- functions
    ApplyTextFormat = function() end,
}

-- Unity没有的API
FairyGUI.FUISprite = 
{
    -- variables
    fillMethod, -- get/set
    fillOrigin, -- get/set
    fillClockwise, -- get/set
    scaleByTile, -- get/set
    fillAmount, -- get/set

    -- functions
    ClearConten = function() end,
    SetScale9Grid = function() end,
    SetGrayed = function() end,
}

-- Unity没有的API
FairyGUI.GBasicTextField = 
{
    -- variables

    -- functions
    SetUnderlineColor = function() end,
}

-- Unity没有的API
FairyGUI.InputProcessor = 
{
    -- variables

    -- functions
    GetRecentInput = function() end,
}

FairyGUI.HtmlObject = 
{
    -- variables
    buttonResource, -- get/set
    inputResource, -- get/set
    selectResource, -- get/set
    usePool, -- get/set

    -- functions
    GetUI = function() end,
    GetElementAttrs = function() end,
    ClearStaticPools = function() end,
}

FairyGUI.PackageItem = 
{
    -- variables
    owner, -- get
    type, -- get
    objectType, -- get
    id, -- get
    name, -- get
    width, -- get
    height, -- get
    file, -- get
    spriteFrame, -- get

    -- functions
    Load = function() end,
    getBranch = function() end,
    getHighResolution = function() end,
}

-- Unity没有的API
FairyGUI.GTree = 
{
    -- variables
    treeNodeRender, -- set
    treeNodeWillExpand, -- set
    indent, -- get/set
    clickToExpand, -- get/set
    rootNode, -- get

    -- functions
    GetSelectedNode = function() end,
    GetSelectedNodes = function() end,
    SelectNode = function() end,
    UnselectNode = function() end,
    ExpandAll = function() end,
    CollapseAll = function() end,
    __call = function() end,
}

-- Unity没有的API
FairyGUI.GTreeNode = 
{
    -- variables
    parent, -- get
    tree, -- get
    cell, -- get
    data, -- get/set
    expanded, -- get/set
    folder, -- get
    text, -- get/set
    icon, -- get/set
    prevSibling, -- get
    nextSibling, -- get
    numChildren, -- get

    -- functions
    __call = function() end,
    AddChild = function() end,
    AddChildAt = function() end,
    RemoveChild = function() end,
    RemoveChildAt = function() end,
    RemoveChildren = function() end,
    GetChildAt = function() end,
    GetChildIndex = function() end,
    SetChildIndex = function() end,
    SetChildIndexBefore = function() end,
    SwapChildren = function() end,
    SwapChildrenAt = function() end,
}

FairyGUI.TextFormat = 
{
    -- variables
    face, -- set
    fontSize, -- set
    color, -- set
    bold, -- set
    italics, -- set
    underline, -- set
    lineSpacing, -- set
    letterSpacing, -- set
    align, -- set
    verticalAlign, -- set
    outlineColor, -- set
    outlineSize, -- set
    shadowColor, -- set
    shadowOffset, -- set
    shadowBlurRadius, -- set
    glowColor, -- set

    -- functions
    SetFormat = function() end,-- (Unity没有的API)
    EnableEffect = function() end,-- (Unity没有的API)
    DisableEffect = function() end,-- (Unity没有的API)
    HasEffect = function() end,-- (Unity没有的API)
}
