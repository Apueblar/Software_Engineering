(define (domain ball-moving-robot)
  (:requirements :strips :typing :action-costs)

  (:types robot room ball arm)

  (:predicates
    (at ?r - robot ?rm - room)       ; robot is in the room
    (inroom ?b - ball ?rm - room)    ; ball is in the room
    (holding ?a - arm ?b - ball)     ; arm holds the ball
    (arm-empty ?a - arm)             ; arm is empty
    (has-arm ?r - robot ?a - arm)    ; arm belongs to a robot
  )

  (:functions
    (total-cost)                     ; accumulated action cost
  )

  ;; Move robot between rooms
  (:action move
    :parameters (?r - robot ?from - room ?to - room)
    :precondition (at ?r ?from)
    :effect (and
      (not (at ?r ?from))
      (at ?r ?to)
      (increase (total-cost) 1)
    )
  )

  ;; Pick up a ball with one arm (robot and ball must be in same room,
  ;; and the arm must belong to the robot)
  (:action pick-up
    :parameters (?r - robot ?a - arm ?b - ball ?rm - room)
    :precondition (and
      (at ?r ?rm)
      (inroom ?b ?rm)
      (arm-empty ?a)
      (has-arm ?r ?a)
    )
    :effect (and
      (holding ?a ?b)
      (not (arm-empty ?a))
      (not (inroom ?b ?rm))
      (increase (total-cost) 1)
    )
  )

  ;; Put down a ball held by an arm (robot deposits ball in current room,
  ;; and the arm must belong to the robot)
  (:action put-down
    :parameters (?r - robot ?a - arm ?b - ball ?rm - room)
    :precondition (and
      (at ?r ?rm)
      (holding ?a ?b)
      (has-arm ?r ?a)
    )
    :effect (and
      (inroom ?b ?rm)
      (arm-empty ?a)
      (not (holding ?a ?b))
      (increase (total-cost) 1)
    )
  )
)
