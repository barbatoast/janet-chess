(def piece-prototype
    @{:set-pos (fn [self x y]
        (set (self :x) x)
        (set (self :y) y))
      :get-pos (fn [self] [(self :x) (self :y)])})

(defn new-piece [color kind x y]
    (table/setproto @{:color color :kind kind :x x :y y
        :id (string color kind x y)} piece-prototype))

(def player-prototype
    @{:add-piece (fn [self kind x y] (array/push (self :pieces)
        (new-piece (self :color) kind x y)))})

(defn new-player [color]
    (table/setproto @{:color color :pieces @[]} player-prototype))
