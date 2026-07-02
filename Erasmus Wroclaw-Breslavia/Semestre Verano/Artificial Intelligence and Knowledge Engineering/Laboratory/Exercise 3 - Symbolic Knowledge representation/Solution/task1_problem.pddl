(define (problem transport-multimodal)
  (:domain package-transport)

  (:objects
    ;; Locations: cities, airports, sea ports
    city-a city-b city-c - location
    airport-a airport-b       - location
    port-a port-b             - location

    ;; Vehicles
    truck1 truck2 - truck
    plane1        - plane
    ship1         - ship

    ;; Packages to deliver
    pkg1 pkg2 pkg3 - package
  )

  (:init
    ;; ------ Vehicle starting positions ------
    (vehicle-at truck1 city-a)
    (vehicle-at truck2 city-c)
    (vehicle-at plane1 airport-a)
    (vehicle-at ship1  port-a)

    ;; ------ Package starting positions ------
    (at pkg1 city-a)   ; must reach city-c
    (at pkg2 city-a)   ; must reach city-b
    (at pkg3 city-c)   ; must reach city-a

    ;; ------ Road network (bidirectional) ------
    (road-connected city-a city-b)    (road-connected city-b city-a)
    (road-connected city-b city-c)    (road-connected city-c city-b)
    (road-connected city-a port-a)    (road-connected port-a city-a)
    (road-connected city-b airport-a) (road-connected airport-a city-b)
    (road-connected city-c port-b)    (road-connected port-b city-c)
    (road-connected city-c airport-b) (road-connected airport-b city-c)

    ;; ------ Air network ------
    (air-connected airport-a airport-b)
    (air-connected airport-b airport-a)

    ;; ------ Sea network ------
    (water-connected port-a port-b)
    (water-connected port-b port-a)

    ;; ------ Road distances (cost units) ------
    (= (road-distance city-a city-b)    5)
    (= (road-distance city-b city-a)    5)
    (= (road-distance city-b city-c)    4)
    (= (road-distance city-c city-b)    4)
    (= (road-distance city-a port-a)    2)
    (= (road-distance port-a city-a)    2)
    (= (road-distance city-b airport-a) 3)
    (= (road-distance airport-a city-b) 3)
    (= (road-distance city-c port-b)    2)
    (= (road-distance port-b city-c)    2)
    (= (road-distance city-c airport-b) 3)
    (= (road-distance airport-b city-c) 3)

    ;; ------ Air distances ------
    (= (air-distance airport-a airport-b) 8)
    (= (air-distance airport-b airport-a) 8)

    ;; ------ Water distances ------
    (= (water-distance port-a port-b) 10)
    (= (water-distance port-b port-a) 10)

    ;; ------ Initial total cost ------
    (= (total-cost) 0)
  )

  (:goal
    (and
      (at pkg1 city-c)   ; pkg1: city-a -> city-c
      (at pkg2 city-b)   ; pkg2: city-a -> city-b
      (at pkg3 city-a)   ; pkg3: city-c -> city-a
    )
  )

  (:metric minimize (total-cost))
)
