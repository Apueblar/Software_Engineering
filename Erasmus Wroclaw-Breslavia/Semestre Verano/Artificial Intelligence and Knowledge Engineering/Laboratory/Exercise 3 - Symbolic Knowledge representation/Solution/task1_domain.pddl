(define (domain package-transport)
  (:requirements :strips :typing :negative-preconditions :numeric-fluents :action-costs)

  (:types
    location vehicle package - object
    truck plane ship - vehicle
  )

  (:predicates
    (at ?p - package ?l - location)
    (vehicle-at ?v - vehicle ?l - location)
    (in ?p - package ?v - vehicle)
    (road-connected ?l1 - location ?l2 - location)
    (air-connected ?l1 - location ?l2 - location)
    (water-connected ?l1 - location ?l2 - location)
  )

  (:functions
    (total-cost)
    (road-distance ?l1 - location ?l2 - location)
    (air-distance ?l1 - location ?l2 - location)
    (water-distance ?l1 - location ?l2 - location)
  )

  ;; Load a package onto a vehicle at the same location
  (:action load
    :parameters (?p - package ?v - vehicle ?l - location)
    :precondition (and
      (at ?p ?l)
      (vehicle-at ?v ?l)
      (not (in ?p ?v))
    )
    :effect (and
      (in ?p ?v)
      (not (at ?p ?l))
      (increase (total-cost) 1)
    )
  )

  ;; Unload a package from a vehicle at the current location
  (:action unload
    :parameters (?p - package ?v - vehicle ?l - location)
    :precondition (and
      (in ?p ?v)
      (vehicle-at ?v ?l)
    )
    :effect (and
      (at ?p ?l)
      (not (in ?p ?v))
      (increase (total-cost) 1)
    )
  )

  ;; Drive a truck along a road connection
  (:action drive
    :parameters (?t - truck ?from - location ?to - location)
    :precondition (and
      (vehicle-at ?t ?from)
      (road-connected ?from ?to)
    )
    :effect (and
      (vehicle-at ?t ?to)
      (not (vehicle-at ?t ?from))
      (increase (total-cost) (road-distance ?from ?to))
    )
  )

  ;; Fly a plane along an air connection
  (:action fly
    :parameters (?p - plane ?from - location ?to - location)
    :precondition (and
      (vehicle-at ?p ?from)
      (air-connected ?from ?to)
    )
    :effect (and
      (vehicle-at ?p ?to)
      (not (vehicle-at ?p ?from))
      (increase (total-cost) (air-distance ?from ?to))
    )
  )

  ;; Sail a ship along a water connection
  (:action sail
    :parameters (?s - ship ?from - location ?to - location)
    :precondition (and
      (vehicle-at ?s ?from)
      (water-connected ?from ?to)
    )
    :effect (and
      (vehicle-at ?s ?to)
      (not (vehicle-at ?s ?from))
      (increase (total-cost) (water-distance ?from ?to))
    )
  )
)
