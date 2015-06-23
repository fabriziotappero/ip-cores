if [ ! -f ./simv ]; then
    make
fi

for f in puzzles/*.hex
do
    ./simv +puz=$f
done

