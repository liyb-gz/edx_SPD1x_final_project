;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname final_project_06) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; ============================
;;          CONSTANTS
;; ============================

(define W 600)
(define H 400)

(define BALL-R 20)

(define MARGIN-W (+ W (* 2 BALL-R)))
(define MARGIN-H (+ H (* 2 BALL-R)))

(define MTS (empty-scene MARGIN-W MARGIN-H))
(define BALL-IMAGE (circle BALL-R "solid" "red"))

(define INIT-X  (/ W 2))
(define INIT-Y  (/ H 2))
(define INIT-DX 10)
(define INIT-DY 0)
(define INIT-G  3)

(define G-UNIT  1)
(define DX-UNIT 1)



;; ============================
;;            DATA
;; ============================

(define-struct ball (x y dx dy g))
;; Ball is (make-ball Natural[0, W] Natural Integer Number Number)
;; interp. a ball with the following properties:
;;         x  - the x position of the ball; cannot go beyond left and right edges
;;         y  - the y position of the ball; 0 is the bottom and H is the top (can go beyond top, but not bottom)
;;         dx - the speed of the ball on the x coordinate (>0 means moving to the right)
;;         dy - the speed of the ball on the y coordinate (>0 means moving to the top)
;;         g  - the gravity the ball (less than 0 means the ball is speeding up to the top)

;; Examples for sitting still
(define B1   (make-ball      0       0   0  0 0)) ;a ball sitting still at the left bottom corner

;; Examples for having gravity but no init speed
(define B2   (make-ball      W       H   0  0 5)) ;a ball at the top right corner, not moving yet, but will start dropping soon
(define B2-1 (make-ball      W       H   0 -5 5)) ;a ball at the top right corner, moving down

;; Examples for having x-speed but no gravity nor y-speed
(define B3   (make-ball     50  (/ H 2)  5  0 0)) ;a ball moving to the right, not dropping
(define B3-1 (make-ball     55  (/ H 2)  5  0 0)) ;a ball moving to the right, not dropping

;; Examples for having x-speed and y-speed but no gravity
(define B4   (make-ball    100       0  -5  5 0)) ;a ball moving to the left, and have a constant speed going up
(define B4-1 (make-ball     95       5  -5  5 0)) ;a ball moving to the left, and have a constant speed going up

;; Examples for having x-speed, y-speed and gravity
(define B5   (make-ball    100     100  -5  5 3)) ;a ball moving to the left and top, but the y speed is dropping
(define B5-1 (make-ball     95     105  -5  2 3)) ;a ball moving to the left and top, but the y speed is dropping
(define B5-2 (make-ball     90     107  -5 -1 3)) ;a ball moving to the left and down, and the y speed is increasing

;; Examples for right edge bounce testing
(define B6   (make-ball (- W 1) (/ H 2)  5  0 0)) ;a ball near the right edge, still moving right, not dropping
(define B6-1 (make-ball      W  (/ H 2) -5  0 0)) ;a ball at the right edge, start moving left, not dropping

;; Examples for left edge bounce testing
(define B7   (make-ball      1  (/ H 2) -5  0 0)) ;a ball near the left edge, still moving left, not dropping
(define B7-1 (make-ball      0  (/ H 2)  5  0 0)) ;a ball at the left edge, start moving right, not dropping

;; Examples for bottom edge bounce testing (no gravity)
(define B8   (make-ball (/ W 2)      2   0 -8 0)) ;a ball near the bottom edge, still moving down, no x speed
(define B8-1 (make-ball (/ W 2)      0   0  8 0)) ;a ball at the bottom edge, start moving up,  no x speed

;; Examples for bottom edge bounce testing (with gravity) - when bouncing, the gravity will not affect
(define B9   (make-ball (/ W 2)      2   0 -8 5)) ;a ball near the bottom edge, still moving down, no x speed
(define B9-1 (make-ball (/ W 2)      0   0  3 5)) ;a ball at the bottom edge, start moving up, no x speed

;; Examples for a ball rolling at the bottom, having gravity and x speed, but y speed keeps 0
(define B10   (make-ball    100      0   5  0 5)) ;a ball near the bottom edge, still moving down, no x speed
(define B10-1 (make-ball    105      0   5  0 5)) ;a ball at the bottom edge, start moving up, no x speed

#;
(define (fn-for-ball b)
  (... (ball-x b)
       (ball-y b)
       (ball-dx b)
       (ball-dy b)
       (ball-g b)))

;; Template rules used:
;;  - compound data: 5 fields



;; ============================
;;          FUNCTIONS
;; ============================

;; Ball -> Ball
;; start the world with (start 0)
;;
(define (main b)
  (big-bang b                           ; Ball
            (on-tick   next-ball)       ; Ball -> Ball
            (to-draw   render-ball)     ; Ball -> Image
            (on-mouse  set-ball)        ; Ball Integer Integer MouseEvent -> Ball
            (on-key    handle-key)))    ; Ball KeyEvent -> Ball

;; Number -> World
;; Helps to launch the world
(define (start n) (main (make-ball INIT-X INIT-Y INIT-DX INIT-DY INIT-G))) 

;; Ball -> Ball
;; produce the next Ball status
(check-expect (next-ball B1) B1)
(check-expect (next-ball B2) B2-1)
(check-expect (next-ball B3) B3-1)
(check-expect (next-ball B4) B4-1)
(check-expect (next-ball B5) B5-1)
(check-expect (next-ball (next-ball B5)) B5-2)
(check-expect (next-ball B6) B6-1)
(check-expect (next-ball B7) B7-1)
(check-expect (next-ball B8) B8-1)
(check-expect (next-ball B9) B9-1)
(check-expect (next-ball B10) B10-1)

#;
(define (next-ball b) b) ;stub

;; template from Ball
(define (next-ball b)
   (make-ball (next-ball-x b)
              (next-ball-y b)
              (next-ball-dx b)
              (next-ball-dy b)
              (ball-g b)))

;; Ball -> Natural[0, W]
;; Generate next Ball's x value (if <0 or >W, stays 0 or W)
(check-expect (next-ball-x B1) (ball-x B1))    ;not moving
(check-expect (next-ball-x B3) (ball-x B3-1))  ;normal
(check-expect (next-ball-x B6) (ball-x B6-1))  ;>W (right edge)
(check-expect (next-ball-x B7) (ball-x B7-1))  ;<0 (left edge)

#;
(define (next-ball-x b) (ball-x b)) ;stub

;; template from Ball
(define (next-ball-x b)
  (cond [(< (+ (ball-x b) (ball-dx b)) 0) 0]
        [(> (+ (ball-x b) (ball-dx b)) W) W]
        [else (+ (ball-x b) (ball-dx b))]))

;; Ball -> Natural
;; Generate next ball's y value (if <0, stays 0)
(check-expect (next-ball-y B1) (ball-y B1))    ;not moving
(check-expect (next-ball-y B4) (ball-y B4-1))  ;normal (no gravity)
(check-expect (next-ball-y B5) (ball-y B5-1))  ;normal (with gravity)
(check-expect (next-ball-y B8) (ball-y B8-1))  ;<0 (bottom edge)

#;
(define (next-ball-y b) (ball-y b)) ;stub

;; template from Ball
(define (next-ball-y b)
  (if (< (+ (ball-y b) (ball-dy b)) 0)
      0
      (+ (ball-y b) (round (ball-dy b)))))

;; Ball -> Integer
;; Generate next ball's speed on x (changes sign if it reaches the left / right edge)
(check-expect (next-ball-dx B1) (ball-dx B1))    ;not moving
(check-expect (next-ball-dx B5) (ball-dx B5-1))  ;normal
(check-expect (next-ball-dx B6) (ball-dx B6-1))  ;right bounce
(check-expect (next-ball-dx B7) (ball-dx B7-1))  ;left bounce

#;
(define (next-ball-dx b) (ball-dx b)) ;stub

;; template from Ball
(define (next-ball-dx b)
    (if (or (< (+ (ball-x b) (ball-dx b)) 0)
            (> (+ (ball-x b) (ball-dx b)) W))
        (- (ball-dx b))
        (ball-dx b)))

;; Ball -> Number
;; Generate next Ball's speed on y (changes sign if it reaches the bottom edge)
(check-expect (next-ball-dy B1)  (ball-dy B1))     ;not moving
(check-expect (next-ball-dy B5)  (ball-dy B5-1))   ;normal (no gravity)
(check-expect (next-ball-dy B6)  (ball-dy B6-1))   ;normal (with gravity)
(check-expect (next-ball-dy B8)  (ball-dy B8-1))   ;bottom bounce (no gravity)
(check-expect (next-ball-dy B9)  (ball-dy B9-1))   ;bottom bounce (with gravity)
(check-expect (next-ball-dy B10) (ball-dy B10-1))  ;bottom rolling (with gravity)

#;
(define (next-ball-dy b) (ball-dy b)) ;stub

;; template from Ball
(define (next-ball-dy b)
   (if (< (+ (ball-y b) (ball-dy b)) 0)
       (- (+ (ball-dy b) (ball-g b)))
       (if (and (= (ball-dy b) 0)
                (= (ball-y b) 0))
           0
           (- (ball-dy b) (ball-g b)))))

;; Ball -> Image
;; render the screen given the Ball 
(check-expect (render-ball B1)
              (place-image BALL-IMAGE
                           (margin-x (ball-x B1))
                           (margin-y (change-y (ball-y B1)))
                           MTS))

#;
(define (render-ball b) MTS) ;stub

;; template from Ball
(define (render-ball b)
  (place-image BALL-IMAGE
               (margin-x (ball-x b))
               (margin-y (change-y (ball-y b)))
               MTS)) 


;; Natural -> Natural
;; Given a y coordinate counting from bottom, produce a y coordinate counting from top, or the opposite
(check-expect (change-y        0)         H)  ; Bottom
(check-expect (change-y        H)         0)  ; Top
(check-expect (change-y (+ H 100))     -100)  ; off screen (top)
(check-expect (change-y      100)  (- H 100)) ; 100 px from bottom

#;
(define (change-y y) y) ;stub

;; template
#;
(define (change-y y)
  ... y)

(define (change-y y) (- H y))

;; Natural -> Natural
;; Given an x coordinate in Ball, produce an x coordinate in the drawing window (make Ball not going out of window)
(check-expect (margin-x 0) BALL-R)               ; the complete ball appears on the left edge
(check-expect (margin-x W) (- MARGIN-W BALL-R))  ; the complete ball appears on the right edge

#;
(define (margin-x x) x) ;stub

;; template
#;
(define (margin-x x) ... x)

(define (margin-x x) (+ x BALL-R))

;; Natural -> Natural
;; Given an y coordinate in Ball from top, produce an y coordinate in the drawing window (make Ball not going out of window)
(check-expect (margin-y 0) BALL-R)
(check-expect (margin-y H) (- MARGIN-H BALL-R))

#;
(define (margin-y y) y) ;stub

;; template
#;
(define (margin-y y) ... y)
  
(define (margin-y y) (+ y BALL-R))

;; Ball Integer Integer MouseEvent -> Ball
;; When a mouse key is pressed down, the ball is repositioned to the coordinates of the mouse.
(check-expect (set-ball B1 30 50 "button-down") (make-ball 30 (change-y 50) 0 0 0))
(check-expect (set-ball B2 30 50 "button-up")   B2)

#;
(define (set-ball b x y me) b) ;stub

;; template from mouse handler
(define (set-ball b x y me)
  (cond [(mouse=? me "button-down")
         (make-ball x
                    (change-y y)
                    (ball-dx b)
                    (ball-dy b)
                    (ball-g b))]
        [else b]))


;; Ball KeyEvent -> Ball
;; Handle KeyEvents and change Ball accordingly:
;;  - left: decrease the Ball's x speed to the right or increase its x speed to the left
;;  - right: increase the Ball's x speed to the right or descrease its x speed to the right
;;  - up: decrease the Ball's gravity
;;  - down: increase the Ball's gravity
;;  - space: reset the Ball to the initial position, speed and gravity
(check-expect (handle-key B1 "left")  (make-ball 0 0 (- 0 DX-UNIT) 0 0))
(check-expect (handle-key B1 "right") (make-ball 0 0 (+ 0 DX-UNIT) 0 0))
(check-expect (handle-key B1 "up")    (make-ball 0 0 0 0 (- 0 1)))
(check-expect (handle-key B1 "down")  (make-ball 0 0 0 0 (+ 0 1)))
(check-expect (handle-key B1 " ")     (make-ball INIT-X INIT-Y INIT-DX INIT-DY INIT-G))
(check-expect (handle-key B1 "a")     B1)

#;
(define (handle-key b ke) b) ;stub

;; template from key hanlder
(define (handle-key b ke)
  (cond [(key=? ke "left")  (make-ball (ball-x b) (ball-y b) (- (ball-dx b) 1) (ball-dy b) (ball-g b))]
        [(key=? ke "right") (make-ball (ball-x b) (ball-y b) (+ (ball-dx b) 1) (ball-dy b) (ball-g b))]
        [(key=? ke "up")    (make-ball (ball-x b) (ball-y b) (ball-dx b) (ball-dy b) (- (ball-g b) 1))]
        [(key=? ke "down")  (make-ball (ball-x b) (ball-y b) (ball-dx b) (ball-dy b) (+ (ball-g b) 1))]
        [(key=? ke " ")     (make-ball INIT-X INIT-Y INIT-DX INIT-DY INIT-G)]
        [else b]))