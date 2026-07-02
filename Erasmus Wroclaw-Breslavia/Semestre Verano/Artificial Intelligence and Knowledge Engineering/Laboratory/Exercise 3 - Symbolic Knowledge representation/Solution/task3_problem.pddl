(define (problem move-balls)
  (:domain ball-moving-robot)

  (:objects
    room1 room2             - room
    robot                   - robot
    ball1 ball2 ball3 ball4 - ball
    arm1 arm2               - arm
  )

  (:init
    ;; Robot starts in room1
    (at robot room1)

    ;; All balls start in room1
    (inroom ball1 room1)
    (inroom ball2 room1)
    (inroom ball3 room1)
    (inroom ball4 room1)

    ;; Both arms are empty
    (arm-empty arm1)
    (arm-empty arm2)

    ;; Both arms belong to the robot
    (has-arm robot arm1)
    (has-arm robot arm2)

    ;; Initial cost
    (= (total-cost) 0)
  )

  (:goal
    (and
      (inroom ball1 room2)
      (inroom ball2 room2)
      (inroom ball3 room2)
      (inroom ball4 room2)
    )
  )

  ;; Minimise total number of actions => forces optimal 11-action plan
  (:metric minimize (total-cost))
)
