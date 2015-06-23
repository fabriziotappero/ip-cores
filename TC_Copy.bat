@ECHO Off
if exist USB_Stimuli.old erase  USB_Stimuli.old
if exist USB_Stimuli.vhd rename USB_Stimuli.vhd USB_Stimuli.old
copy  %1 USB_Stimuli.vhd

