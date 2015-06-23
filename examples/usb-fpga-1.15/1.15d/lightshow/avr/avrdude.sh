make || exit 
avrdude -p x128a1 -c avrispmkii -P usb -e -U flash:w:test.ihx:i
