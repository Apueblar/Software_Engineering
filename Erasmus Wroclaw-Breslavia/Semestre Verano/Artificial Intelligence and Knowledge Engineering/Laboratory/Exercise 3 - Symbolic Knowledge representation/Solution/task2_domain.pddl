(define (domain cleaning-robot)
  (:requirements :strips :typing)

  (:types robot room)

  (:predicates
    (at ?r - robot ?p - room)      ; robot is in the room
    (dirty ?p - room)              ; room is dirty
    (clean ?p - room)              ; room is clean
    (connected ?r1 - room ?r2 - room) ; rooms are adjacent
  )

  ;; Move the robot from one room to an adjacent room
  (:action move
    :parameters (?r - robot ?from - room ?to - room)
    :precondition (and
      (at ?r ?from)
      (connected ?from ?to)
    )
    :effect (and
      (at ?r ?to)
      (not (at ?r ?from))
    )
  )

  ;; Clean the current room (must be dirty)
  (:action clean
    :parameters (?r - robot ?p - room)
    :precondition (and
      (at ?r ?p)
      (dirty ?p)
    )
    :effect (and
      (clean ?p)
      (not (dirty ?p))
    )
  )
)
