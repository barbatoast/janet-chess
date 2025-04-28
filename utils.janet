(defn reverse-board [board]
    (reverse board))

(defn print-board [board]
    (each row board
        (print (string/join (map (fn [x] (string/format "%3d" x)) row) " "))))

(defn random-move [moves]
    (def idx (math/rng-int (math/rng (os/cryptorand 8)) (length moves)))
    (moves idx))
