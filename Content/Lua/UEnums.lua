
local UEnums = {}

UEnums.ESlateVisibility = {
    Visible = 0,                        --Default widget visibility - visible and can interact with the cursor
    Collapsed = 1,                      --Not visible and takes up no space in the layout; can never be clicked on because it takes up no space.
    Hidden = 2,                         --Not visible, but occupies layout space. Not interactive for obvious reasons.
    HitTestInvisible = 3,               --Visible to the user, but only as art. The cursors hit tests will never see this widget.
    SelfHitTestInvisible = 4            --Same as HitTestInvisible, but doesn't apply to child widgets.
}

UEnums.EBlendMode = {
    BLEND_Opaque = 0,
    BLEND_Masked = 1,
    BLEND_Translucent = 2,
    BLEND_Additive = 3,
    BLEND_Modulate = 4,
    BLEND_AlphaComposite =5,
    BLEND_MAX = 6,
}

UEnums.EAttachmentRule = {
    KeepRelative = 0,
    KeepWorld = 1,
    SnapToTarget = 2,
}

UEnums.EMontagePlayReturnType = {
    MontageLength = 0,
    Duration = 1,
}

return UEnums