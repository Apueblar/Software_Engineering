import input_output
import game_logic
import time
turns = 0
game_logic.hull = 8
game_logic.shield = 4

input_output.start()

game_logic.difficulty()

game_logic.select_game_mode()

game_logic.increment_active_threats()
game_logic.increment_active_threats()

while (len(game_logic.possible_threats) != 0 or game_logic.count_external_threats() != 0) and game_logic.hull > 0 and len(game_logic.available_crew) > 0:
  time.sleep(3)
  input_output.clear_screen()
  
  # 1. Roll crew members (Terminado)
  input_output.ask_for_roll(len(game_logic.available_crew))
  time.sleep(0.025)
  game_logic.roll_crew_members()
  time.sleep(0.005)
  
  # 2. Scan for threats (Terminado)
  game_logic.scan_for_threats()
  time.sleep(0.1)
  
  # 3. Assign crew
  while len(game_logic.available_crew) != 0 or len(game_logic.total_damage) != 0 or len(game_logic.total_heal):
    user = input_output.main_menu()
    user = game_logic.number_into_crew(user)
    if user == "0":
      if input_output.end_assignment() == "1":
        break
      else:
        continue
    elif user == "6":
      input_output.attack()
    elif user == "7":
      input_output.repair_hull()
    else:
      ability = input_output.power_options(user)
      if ability == "0":
        continue
      else:
        game_logic.ability_activation(user, ability)

  # Clears the attack after the execution
  game_logic.tacticals_assigned.clear()
  game_logic.total_damage.clear()

  # Clears the repair after the execution
  game_logic.engineers_assigned.clear()
  game_logic.total_heal.clear()
  
  # Pass all the crew to the return list
  for crew in game_logic.available_crew:
    game_logic.return_crew.append(crew)
  game_logic.available_crew.clear()
  
  # 4. Discover new threats (Terminado)
  game_logic.increment_active_threats()
  
  if game_logic.carta20 in game_logic.active_threats:
    for crew in game_logic.tacticals_assigned:
      game_logic.infirmary.append(crew)
    game_logic.tacticals_assigned.clear()
    game_logic.active_threats.remove(game_logic.carta20)
    
  if game_logic.carta26 in game_logic.active_threats and len(game_logic.distracted_crew) < 1 and len(game_logic.return_crew) > 0:
    game_logic.distracted_crew.append(game_logic.return_crew[0])
    game_logic.return_crew.pop(0)
  time.sleep(0.025)
    
  # 5. Active threats
  while game_logic.hull != 0:
    input_output.show_active_threats(game_logic.active_threats)
    input_output.ask_for_roll(1, "threat")
    s, h, die = game_logic.activate_threat(game_logic.shield, game_logic.hull)
    game_logic.shield = s
    game_logic.hull = h

    if game_logic.carta24 not in game_logic.active_threats or die != 2:
      break
  
  # 6. Gather up crew (Terminado)
  for threat in game_logic.stasis_beam:
    game_logic.active_threats.append(threat)
  game_logic.stasis_beam.clear()
  game_logic.gather_up_crew(game_logic.return_crew)

  turns += 1

# The game finished
if (game_logic.hull <= 0) or len(game_logic.available_crew) == 0:
  input_output.game_over()
  input_output.final_score(turns, "lose")
else:
  input_output.you_win()
  input_output.final_score(turns, "win")