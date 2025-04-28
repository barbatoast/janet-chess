(import jaylib :as jl)
(use ./piece-square-tables)
(use ./player)
(use ./utils)

(def- screen-width 800)
(def- screen-height 700)

(def- light-color 0xeeeed2ff)
(def- dark-color  0x769656ff)
(def- tile-size   80)
(var- spritesheet nil)

(var- current-message "Player move")
(var- tile-select? false)
(var- piece-id "whitepawn34")
(var- player-x 3)
(var- player-y 3)
(var- player-cur [(* 3 tile-size) (* 4 tile-size)])
(var- player-end [(* 3 tile-size) (* 3 tile-size)])

(var- game-state :player-move)
(var- player (new-player :white))
(var- enemy (new-player :black))

(defn- get-piece-by-id [id]
    (first (filter (fn [x] (= (x :id) id)) [;(player :pieces) ;(enemy :pieces)])))

(defn- get-piece-by-pos [x y]
    (first (filter (fn [piece]
        (if (and (= (piece :x) x) (= (piece :y) y)) true false)) (player :pieces))))

(defn- get-sprite-pos [piece]
    (match [(piece :color) (piece :kind)]
        [:white :king]   [0 0]
        [:white :queen]  [1 0]
        [:white :knight] [3 0]
        [:white :rook]   [4 0]
        [:white :pawn]   [5 0]
        [:black :king]   [0 1]
        [:black :queen]  [1 1]
        [:black :knight] [3 1]
        [:black :rook]   [4 1]
        [:black :pawn]   [5 1]))

(defn- load-assets []
    (def pieces (jl/load-image-1 "resources/Pieces.png"))
    (jl/image-resize pieces (* tile-size 6) (* tile-size 2))
    (def pieces-t (jl/load-texture-from-image pieces))
    (set spritesheet pieces-t))

(defn- draw-board []
    (loop [x :range [0 6]]
        (loop [y :range [0 6]]
            (let [tile-color (if (even? (% (+ x y) 2)) light-color dark-color)]
                (jl/draw-rectangle (* x tile-size) (* y tile-size)
                    tile-size tile-size tile-color)))))

(defn- get-piece-rec [[x y]]
    [(* x tile-size) (* y tile-size) tile-size tile-size])

(defn- get-piece-dest [[x y]]
    [(* x tile-size) (* y tile-size)])

(defn- draw-pieces []
    (each piece [;(player :pieces) ;(enemy :pieces)]
        (def sprite-pos (get-sprite-pos piece))
        (def moving? (or (= game-state :player-move) (= game-state :enemy-move)))
        (def piece-moving? (and moving? (= (piece :id) piece-id)))
        (when (not piece-moving?)
            (jl/draw-texture-rec spritesheet
                (get-piece-rec sprite-pos) (get-piece-dest (:get-pos piece)) :white))))

(defn- move-piece []
    (def piece (get-piece-by-id piece-id))
    (def sprite-pos (get-sprite-pos piece))
    (set player-cur [(player-cur 0) (- (player-cur 1) 4)])
    (jl/draw-texture-rec spritesheet
        (get-piece-rec sprite-pos) player-cur :white)
    (when (= player-cur player-end)
        (:set-pos piece 3 3)
        (set game-state :player-turn)))

(defn- draw-coordinates []
    (jl/draw-text "A"  30 500 20 :black)
    (jl/draw-text "B" 110 500 20 :black)
    (jl/draw-text "C" 190 500 20 :black)
    (jl/draw-text "D" 270 500 20 :black)
    (jl/draw-text "E" 350 500 20 :black)
    (jl/draw-text "F" 430 500 20 :black)
    (jl/draw-text "1" 510 430 20 :black)
    (jl/draw-text "2" 510 350 20 :black)
    (jl/draw-text "3" 510 270 20 :black)
    (jl/draw-text "4" 510 190 20 :black)
    (jl/draw-text "5" 510 110 20 :black)
    (jl/draw-text "6" 510  30 20 :black))

(defn- draw-current-message []
    (jl/draw-text current-message 30 600 20 :black))

(defn- get-grid-coordinates [x y]
    (def grid-x (match x
        0 "a" 1 "b" 2 "c" 3 "d" 4 "e" 5 "f"))
    (def grid-y (match y
        0 "6" 1 "5" 2 "4" 3 "3" 4 "2" 5 "1"))
    [grid-x grid-y])

(defn- in-grid-bounds [x y]
    (and (>= x 0) (>= y 0) (< x 6) (< y 6)))

(defn- check-mouse []
    (when (jl/mouse-button-down? :left)
        (def [mx my] (jl/get-mouse-position))
        (def [px py] (map (fn [x] (math/floor (/ x 80))) [mx my]))
        (def piece (get-piece-by-pos px py))
        (when (and (in-grid-bounds px py) (not= piece nil))
            (set tile-select? true)
            (set player-x px)
            (set player-y py)
            (set current-message (string/format "selected piece %s %s, %s"
                (string (piece :kind)) ;(get-grid-coordinates px py))))))

(defn- get-tile-rec [x y]
    [(* x tile-size) (* y tile-size) 80 80])

(defn- draw-tile-select []
    (when (and (= game-state :player-turn) tile-select?)
        (jl/draw-rectangle-lines-ex (get-tile-rec player-x player-y) 2.0 :red)))

(defn- initialize-pieces []
    (:add-piece enemy  :rook   0 0)
    (:add-piece enemy  :knight 1 0)
    (:add-piece enemy  :queen  2 0)
    (:add-piece enemy  :king   3 0)
    (:add-piece enemy  :knight 4 0)
    (:add-piece enemy  :rook   5 0)
    (:add-piece enemy  :pawn   0 1)
    (:add-piece enemy  :pawn   1 1)
    (:add-piece enemy  :pawn   2 1)
    (:add-piece enemy  :pawn   3 1)
    (:add-piece enemy  :pawn   4 1)
    (:add-piece enemy  :pawn   5 1)
    (:add-piece player :pawn   0 4)
    (:add-piece player :pawn   1 4)
    (:add-piece player :pawn   2 4)
    (:add-piece player :pawn   3 4)
    (:add-piece player :pawn   4 4)
    (:add-piece player :pawn   5 4)
    (:add-piece player :rook   0 5)
    (:add-piece player :knight 1 5)
    (:add-piece player :queen  2 5)
    (:add-piece player :king   3 5)
    (:add-piece player :knight 4 5)
    (:add-piece player :rook   5 5))

(defn main [& args]
    (jl/init-window screen-width screen-height "Chess")
    (jl/set-target-fps 60)
    (load-assets)
    (initialize-pieces)
    (print-board king-pst)
    (print "------- Rotate! -------")
    (print-board (reverse-board king-pst))

    (while (not (jl/window-should-close))
        (jl/begin-drawing)
        (jl/clear-background :white)
        (draw-board)
        (draw-pieces)
        (draw-coordinates)
        (draw-current-message)
        (match game-state
            :player-turn (do (draw-tile-select) (check-mouse))
            :player-move (move-piece))
        (jl/end-drawing))

    (jl/close-window))
