for a in ~/.local/share/applications/waydroid.*.desktop; do
    grep -q NoDisplay $a || sed '/^Icon=/a NoDisplay=true' -i $a
done
