if nil == FairyGUI then
	return
end

FairyGUI.UIEventType = {
	Enter = 0,
	Exit = 1,
	Changed = 2,
	Submit = 3,

	TouchBegin = 10,
	TouchMove = 11,
	TouchEnd = 12,
	Click = 13,
	RollOver = 14,
	RollOut = 15,
	MouseWheel = 16,
	RightClick = 17,
	MiddleClick = 18,

	PositionChange = 20,
	SizeChange = 21,

	KeyDown = 30,
	KeyUp = 31,

	Scroll = 40,
	ScrollEnd = 41,
	PullDownRelease = 42,
	PullUpRelease = 43,

	ClickItem = 50,
	ClickLink = 51,
	ClickMenu = 52,
	RightClickItem = 53,

	DragStart = 60,
	DragMove = 61,
	DragEnd = 62,
	Drop = 63,

	GearStop = 70,

	OnInit = 100,
	OnShown = 101,
	OnHide = 102,
    DoShowAnimation = 103,
    DoHideAnimation = 104,
}

FairyGUI.PackageItemType = {
	Image = 0,
	MovieClip = 1,
	Sound = 2,
	Component = 3,
	Atlas = 4,
	Font = 5,
	Swf = 6,
	Misc = 7,
	Unknown = 8,
	Spine = 9,
	DragoneBones = 10
}

FairyGUI.ObjectType = {
	Image = 0,
	MovieClip = 1,
	Swf = 2,
	Graph = 3,
	Loader = 4,
	Group = 5,
	Text = 6,
	RichText = 7,
	InputText = 8,
	Component = 9,
	List = 9,
	Label = 10,
	Button = 11,
	ComboBox = 12,
	ProgressBar = 13,
	Slider = 14,
	ScrollBar = 15,
	Tree = 16,
	Loader3D = 17
}

FairyGUI.ButtonMode = {
	Common = 0,
	Check = 1,
	Radio = 2
}

FairyGUI.ChildrenRenderOrder = {
	Ascent = 0,
	Descent = 1,
	Arch = 2,
}

FairyGUI.OverflowType = {
	Horizontal = 0,
	Vertical = 1,
	Both = 2
}

FairyGUI.ScrollType = {
	HORIZONTAL = 0,
	VERTICAL = 1,
	BOTH = 2
}

FairyGUI.ScrollBarDisplayType = {
	Default = 0,
	Visible = 1,
	Auto = 2,
	Hidden = 3
}

FairyGUI.FillType = {
	None = 0,
	Scale = 1,
	ScaleMatchHeight = 2,
	ScaleMatchWidth = 3,
	ScaleFree = 4,
	ScaleNoBorder = 5
}

FairyGUI.ProgressTitleType = {
	Percent = 0,
	ValueAndMax = 1,
	Value = 2,
	Max = 3
}

FairyGUI.ListLayoutType = {
	SingleColumn = 0,
	SingleRow = 1,
	FlowHorizontal = 2,
	FlowVertical = 3,
	Pagination = 4
}

FairyGUI.ListSelectionMode = {
	Single = 0,
	Multiple = 1,
	Multiple_SingleClick = 2,
	None = 3
}

FairyGUI.GroupLayoutType = {
	None = 0,
	Horizontal = 1,
	Vertical = 2
}

FairyGUI.PopupDirection = {
	Auto = 0,
	Up = 1,
	Down = 2
}

FairyGUI.AutoSizeType = {
	None = 0,
	Both = 1,
	Height = 2,
	Shrink = 3
}

FairyGUI.FlipType = {
	None = 0,
	Horizontal = 1,
	Vertical = 2,
	Both = 3
}

FairyGUI.TransitionActionType = {
	XY = 0,
	Size = 1,
	Scale = 2,
	Pivot = 3,
	Alpha = 4,
	Rotation = 5,
	Color = 6,
	Animation = 7,
	Visible = 8,
	Sound = 9,
	Transition = 10,
	Shake = 11,
	ColorFilter = 12,
	Skew = 13,
	Text = 14,
	Icon = 15,
	Unknown = 16
}

FairyGUI.FillMethod = {
	None = 0,
	Horizontal = 1,
	Vertical = 2,
	Radial90 = 3,
	Radial180 = 4,
	Radial360 = 5,
}

FairyGUI.FillOrigin = {
	Top = 0,
	Bottom = 1,
	Left = 2,
	Right = 3
}

FairyGUI.ObjectPropID = {
	Text = 0,
	Icon = 1,
	Color = 2,
	OutlineColor = 3,
	Playing = 4,
	Frame = 5,
	DeltaTime = 6,
	TimeScale = 7,
	FontSize = 8,
	Selected = 9
}

FairyGUI.TextEffect = {
	OUTLINE = 1,
	SHADOW = 2,
	GLOW = 4
}


FairyGUI.RelationType = {
    Left_Left = 0,
    Left_Center = 1,
    Left_Right = 2,
    Center_Center = 3,
    Right_Left = 4,
    Right_Center = 5,
    Right_Right = 6,

    Top_Top = 7,
    Top_Middle = 8,
    Top_Bottom = 9,
    Middle_Middle = 10,
    Bottom_Top = 11,
    Bottom_Middle = 12,
    Bottom_Bottom = 13,

    Width = 14,
    Height = 15,

    LeftExt_Left = 16,
    LeftExt_Right = 17,
    RightExt_Left = 18,
    RightExt_Right = 19,
    TopExt_Top = 20,
    TopExt_Bottom = 21,
    BottomExt_Top = 22,
    BottomExt_Bottom = 23,

    Size = 24
};

FairyGUI.AlignType = {
	Left = 0,
	Center = 1,
	Right = 2
}

FairyGUI.VertAlignType = {
	Top = 0,
	Middle = 1,
	Bottom = 2
}


FairyGUI.TweenPropType = {
    None = 0,
    X = 1,
    Y = 2,
	
    Position = 3,
    Width = 4,
    Height = 5,
    Size = 6,
    ScaleX = 7,
    ScaleY = 8,
    Scale = 9,
    Rotation = 10,
    Alpha = 11,
    Progress = 12
}


FairyGUI.EaseType = {
    Linear = 0,
    SineIn = 1,
    SineOut = 2,
    SineInOut = 3,
    QuadIn = 4,
    QuadOut = 5,
    QuadInOut = 6,
    CubicIn = 7,
    CubicOut = 8,
    CubicInOut = 9,
    QuartIn = 10,
    QuartOut = 11,
    QuartInOut = 12,
    QuintIn = 13,
    QuintOut = 14,
    QuintInOut = 15,
    ExpoIn = 16,
    ExpoOut = 17,
    ExpoInOut = 18,
    CircIn = 19,
    CircOut = 20,
    CircInOut = 21,
    ElasticIn = 22,
    ElasticOut = 23,
    ElasticInOut = 24,
    BackIn = 25,
    BackOut = 26,
    BackInOut = 27,
    BounceIn = 28,
    BounceOut = 29,
    BounceInOut = 30,
    Custom = 31,
}

-- UI事件订阅键值
FGUIEventKey = {
    onChanged          = FairyGUI.UIEventType.Changed         ,
    onSubmit           = FairyGUI.UIEventType.Submit          ,
    onTouchBegin       = FairyGUI.UIEventType.TouchBegin      ,
    onTouchMove        = FairyGUI.UIEventType.TouchMove       ,
    onTouchEnd         = FairyGUI.UIEventType.TouchEnd        ,
    onClick            = FairyGUI.UIEventType.Click           ,
    onRollOver         = FairyGUI.UIEventType.RollOver        ,
    onRollOut          = FairyGUI.UIEventType.RollOut         ,
    onMouseWheel       = FairyGUI.UIEventType.MouseWheel      ,
    onRightClick       = FairyGUI.UIEventType.RightClick      ,
    onMiddleClick      = FairyGUI.UIEventType.MiddleClick     ,
    onPositionChanged  = FairyGUI.UIEventType.PositionChange  ,
    onSizeChanged      = FairyGUI.UIEventType.SizeChange      ,
    onKeyDown          = FairyGUI.UIEventType.KeyDown         ,
    onScroll           = FairyGUI.UIEventType.Scroll          ,
    onScrollEnd        = FairyGUI.UIEventType.ScrollEnd       ,
    onPullDownRelease  = FairyGUI.UIEventType.PullDownRelease ,
    onPullUpRelease    = FairyGUI.UIEventType.PullUpRelease   ,
    onClickItem        = FairyGUI.UIEventType.ClickItem       ,
    onClickLink        = FairyGUI.UIEventType.ClickLink       ,
    onRightClickItem   = FairyGUI.UIEventType.RightClickItem  ,
    onDragStart        = FairyGUI.UIEventType.DragStart       ,
    onDragMove         = FairyGUI.UIEventType.DragMove        ,
    onDragEnd          = FairyGUI.UIEventType.DragEnd         ,
    onDrop             = FairyGUI.UIEventType.Drop            ,
    onGearStop         = FairyGUI.UIEventType.GearStop        ,
	onInit         	   = FairyGUI.UIEventType.OnInit          ,
	onShown            = FairyGUI.UIEventType.OnShown         ,
	onHide             = FairyGUI.UIEventType.OnHide          ,
	doShowAnimation	   = FairyGUI.UIEventType.DoShowAnimation ,
	doHideAnimation    = FairyGUI.UIEventType.DoHideAnimation ,
}