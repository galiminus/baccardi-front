angular.module("app").config ($mdIconProvider) ->
	$mdIconProvider
		.icon("menu"       , "/images/ic_more_vert_24px.svg"          , 24)
		.icon("close"      , "/images/ic_close_24px.svg"              , 24)
		.icon("spending"   , "/images/ic_trending_down_24px.svg"      , 24)
		.icon("income"     , "/images/ic_trending_up_24px.svg"        , 24)
		.icon("settings"   , "/images/ic_settings_24px.svg"           , 24)
		.icon("disconnect" , "/images/ic_do_not_disturb_24px.svg"     , 24)