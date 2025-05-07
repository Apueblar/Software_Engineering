import game_logic
import os
import time

def clear_screen():
  if os.name == "posix": os.system ("clear") 
  else: os.system ("cls")

def start():
  '''Función usada al inicio del juego, para título e instrucciones.'''
  print("""
______  _____  _____ ______    _____ ______   ___   _____  _____   ______           ____ 
|  _  \|  ___||  ___|| ___ \  /  ___|| ___ \ / _ \ /  __ \|  ___|  |  _  \         / ___|
| | | || |__  | |__  | |_/ /  \ `--. | |_/ // /_\ \| /  \/| |__    | | | | ______ / /___ 
| | | ||  __| |  __| |  __/    `--. \|  __/ |  _  || |    |  __|   | | | ||______|| ___ \\
| |/ / | |___ | |___ | |      /\__/ /| |    | | | || \__/\| |___   | |/ /         | \_/ |
|___/  \____/ \____/ \_|      \____/ \_|    \_| |_/ \____/\____/   |___/          \_____/
""")
  print("By Álvaro, Javier and Adrián")
  time.sleep(0.05)
  text = """
  You are the Captain of the USS Crypsis - a RPTR
  class starship on routine patrol of the Auborne
  system when a distress call was received. Upon
  warping in you quickly realize it was a trap! With
  the help of your crew, you must survive until a
  rescue fleet appears.
  """
  for i in text:
    print(i, end="")
    time.sleep(0.005)
  print()
  time.sleep(1)
  text = """
  Deep Space D-6 is a solitaire dice game about
  survival in uncharted deep space. Each turn you’ll
  roll Crew dice and assign them to a station or
  mission. You must deal with internal and external
  threats to your ship. Surive to win.
  """
  for i in text:
    print(i, end="")
    time.sleep(0.005)
  print()
  time.sleep(1)
  text = """
  To win, you must survive by destroying all external
  threats in the threat deck.
  """
  for i in text:
    print(i, end="")
    time.sleep(0.005)
  print()
  time.sleep(1)

def select_game_mode():
  '''
  Función usada al inicio del juego, para preguntar que modo de juego quiere.
  Creado por: Álvaro P.
  '''
  print("Choose what type of mode do you want to play:")
  time.sleep(0.025)
  print("1. Normal game")
  print("2. Shortened game (Remove 5 possible threats)")
  print("3. Fast game (Remove 8 possible threats)")
  game_mode = 0
  while game_mode not in (1,2,3):
    try:
      game_mode = int(input(">>> "))
    except ValueError:
      print("Invalid option")
      print("Choose (1, 2 or 3):")
    if game_mode not in (1,2,3):
      print("Invalid option")
      print("Choose (1, 2 or 3):")

  time.sleep(0.025)
  print("Chosen option: ", end="")
  if game_mode == 1:
    print("Normal game")
  elif game_mode == 2:
    print("Shortened game")
  else:
    print("Fast game")
  time.sleep(0.05)
  return game_mode

def ask_for_roll(number, type = "crew"):
  '''
  Función que pide al usuario que le de al enter para tirar los dados.
  Creada por: Álvaro P.
  '''
  if number == 1: 
    input(f"Press enter to throw 1 {type} die.")
  else: 
    input(f"Press enter to throw {number} {type} dices.")
  print()

def show_active_threats(threats):
  '''
  Función que muestra los threats activos.
  input: threats (list)
  Creada por: Álvaro P.
  '''
  if len(threats) == 0:
    print()
    print("There are no active threats.")
    print()
  else:
    print()
    print("ACTIVE THREATS:")
  for threat in threats:
    nombre = threat["nombre"]
    print(f'{nombre}: ', end=(" " * (21 - len(nombre))))
    
    print(f'Type - {threat["tipo"]}', end="")
    
    if threat["tipo"] == "External":
      if threat["level"] != 0:
        print(" / Level: ", end="")
        print(threat["level"], end="")
      else:
        print(" / After been used is descarted", end="")
      
      print(" / Damage to Shields: ", end="")
      shield_damage = threat["damage"][0]
      if shield_damage == -1:
        print("Destroys Shields", end="")
      elif shield_damage == -2:
        print("Shields Offline", end="")
      else:
        print(f"{shield_damage}", end="")
        
      ship_damage = threat["damage"][1]
      print(" / Damage to Health: ", end="")
      print(f"{ship_damage}", end="")

      if "special_effect" in threat:
        print(" / ", end="")
        print(threat["special_effect"], end="")

      print(" / Activated: ", end="")
      if threat["activated"] == ["if Hull damage"]: print("If you lost Hull this round", end="")
      elif threat["activated"] == ["if not threats activated"]: print("If no threats have been activated this round", end="")
      else:
        print(threat["activated"],end="")

      if "when destroyed" in threat:
        print(f" / When destroyed: {threat['when destroyed']}", end="")
    
    elif threat["tipo"] == "Internal":
      if "initial" in threat:
        print(" / First: ", end="")
        print(threat["initial"], end="")

      print(" / ", end="")
      print(threat["effect"], end="")

      if "level" in threat:
        print(" / After been used is descarted", end="")

      if "final" in threat:
        print(" / When discarted: ", end="")
        print(threat["final"], end="")

      if "activated" in threat:
        print(" / Activated: ", end="")
        print(threat["activated"],end="")

    if "counter" in threat:
      print(" / Counter: ", end="")
      counters = threat["counter"]
      if isinstance(counters[0], int): 
        for i in range(1,len(counters),2):
          if i != 1: print(" and ", end="")
          if counters[i-1] > 1: print(f"{counters[i-1]} {counters[i]}s", end="")
          else: print(f"{counters[i-1]} {counters[i]}", end="")
      else:
        for i in range(len(counters) - 1):
          for j in range(1,len(counters[i]) - 2,2):
            print(f"{counters[i][j-1]} {counters[i][j]}", end=" and ")
          print(f"{counters[i][-2]} {counters[i][-1]}", end=" or ")
        print(f"{counters[-1][-2]} {counters[-1][-1]}", end="")

    print()
 
def show_new_threat(threat):
  '''
  Función que muestra un threat nuevo.
  input: threats (dictionary)
  Creado por: Álvaro P.
  '''
  print("")
  print("DANGER!")
  print(f'The new threat {threat["nombre"]} has been activated.')

def select_difficulty():
  '''
  Función que selecciona la dificultad del juego.
  Creada por: Álvaro P.
  '''
  print("Select a difficulty:")
  time.sleep(0.025)
  print("1 - Easy")
  print("2 - Medium")
  print("3 - Hard")
  difficulty = 0
  while difficulty not in (1,2,3):
    try:
      difficulty = int(input(">>> "))
    except ValueError:
      print("Invalid option")
      print("Choose (1, 2 or 3):")
    if difficulty not in (1,2,3):
      print("Invalid option")
      print("Choose (1, 2 or 3):")

  time.sleep(0.025)
  print("Chosen option: ", end="")
  if difficulty == 1:
    print("Easy")
  elif difficulty == 2:
    print("Medium")
  else:
    print("Hard")
  print("")
  time.sleep(0.05)
  return difficulty

def dont_panic():
  '''
  Función usada si el threat es la carta don't panic.
  Creada por: Álvaro P.
  '''
  print("")
  print("Don't panic!, luck is on your side.")
  print("The threats remain the same.")
  print("")

def game_over():
  '''
  Función usada al perder el juego.
  Created by Javier
  '''
  n = 35
  while n >= 0:
      clear_screen()
      print('\n' * n)
      print("*********************************************")
      print("***************** You lost! *****************")
      print("********** The hull was destroyed. **********")
      print("*********************************************")
      n -= 1
      time.sleep(0.025)

def no_threats_left():
  '''Función usada cuando no quedan possible threats.'''
  print("")
  print("There are no threats left.")
  print("Destroy the active ones and win the game.")
  print("")

def you_win():
  '''
  Función usada al ganar el juego.
  Created by Javier
  '''
  n = 40
  while n >= 0:
      clear_screen()
      print('\n' * n)
      print("*" * 50)
      print("******************* You won! *********************")
      print("*********** All threats were destroyed. **********")
      print("**************************************************")
      n -= 1
      time.sleep(0.1)

def found_a_threat(threat_until):
  '''
  Función usada cuando se encuentra un threat.
  input: threat_until (int)
  Creada por: Álvaro P.
  '''
  print("We found a threat!")
  if threat_until == 0:
      print("Fatal damage.")
      print("We manage to restart the problem, but a threat was activated.")
  else:
      print(f"We have {threat_until} threats left until disaster.")
  print("")

def show_available_crew():
  '''
  Function that shows the available crew.
  Creada por : Javier
  '''
  print("The available crew are:")
  for i in range(len(game_logic.available_crew)):
    print(f'Crew member {i + 1}: {game_logic.available_crew[i]}')
    time.sleep(0.025)
    
def ability_use():
  '''
  Function that ask if the user wants to use the abilities of that crew member.
  Creado por: Javier
  '''
  use = input("Do you want to use the ability? (yes/no)").lower
  while use not in ("yes", "no"):
    use = input("Do you want to use the ability? (yes/no)").lower
  return use

def power_options(crew_members):
  '''
  Function that shows the options of the powers of the crew member.
  Creada por: Javier
  Small update of the function that included the ability to assign
  some crew die to threats.
  Returns a number according to the option chosen.
  Updated by: Adrián S.
  '''
  if crew_members == "commander":
    while True:
      check_list = []
      print("You can: ")
      print("0 - Go back")
      check_list.append("0")
      print("1 - Change another crew die to one of your choice")
      check_list.append("1")
      print("2 - Re-roll all crew dice that have not yet been assigned")
      check_list.append("2")
      if (game_logic.carta18 in game_logic.active_threats):
        print("3 - Assign a commander to the Hijackers threat")
        check_list.append("3")
      if (game_logic.carta24 in game_logic.active_threats) and (game_logic.cloaked_threats.count("commander") != 1):
        print("4 - Assign a commander to the Cloaked Threats threat")
        check_list.append("4")
      print()
      print("Select option: ", end="")
      user = input()
      print()
      if game_logic.validate_input(user, check_list, "That option is not available"):
        break
    return user
    
  elif crew_members == "tactical":
    while True:
      check_list = []
      print("You can: ")
      print("0 - Go back")
      check_list.append("0")
      print("1 - Assign a tactical for attacking")
      check_list.append("1")
      if (game_logic.carta33 in game_logic.active_threats):
        print("2 - Assign a tactical to the Invaders threat")
        check_list.append("2")
      print()
      print("Select option: ", end="")
      user = input()
      print()
      if game_logic.validate_input(user, check_list, "That option is not available"):
        break
    return user

  elif crew_members == "medic":
    while True:
      check_list = []
      print("You can: ")
      print("0 - Go back")
      check_list.append("0")
      if len(game_logic.infirmary) > 0:
        print("1 - Return all crew from the Infirmary back into your available pool")
        check_list.append("1")
      if len(game_logic.threats_crew) > 0:
        print("2 - Return a Threat die that has been locked in the Scanners")
        check_list.append("2")
      if (game_logic.carta26 in game_logic.active_threats):
        print("3 - Assign a medic to the Distracted threat")
        check_list.append("3")
      if (game_logic.carta30 in game_logic.active_threats):
        print("4 - Assign a medic to the Panel Explosion threat")
        check_list.append("4")
      if (game_logic.carta32 in game_logic.active_threats):
        print("5 - Assign a medic to the Pandemic threat")
        check_list.append("5")
      print()
      print("Select option: ", end="")
      user = input()
      print()
      if game_logic.validate_input(user, check_list, "That option is not available"):
        break
    return user

  elif crew_members == "scientist":
    while True:
      check_list = []
      print("You can: ")
      print("0 - Go back")
      check_list.append("0")
      if (game_logic.carta21 in game_logic.active_threats):
        print("1 - Assign a scientist to the Cosmic Existencislism threat.")
        check_list.append("1")
      else:
        if (game_logic.carta22 in game_logic.active_threats):
          print("While Nebula is active, the shields cannot be repaired")
        else:
          print("1 - Recharge shields to maximum")
          check_list.append("1")
        if len(game_logic.active_threats) > 0:
          print("2 - Fire the Stasis Beam")
          check_list.append("2")
        if (game_logic.carta24 in game_logic.active_threats) and (game_logic.cloaked_threats.count("scientist") != 1):
          print("3 - Assign a scientist to the Cloaked Threats threat")
          check_list.append("3")
        if (game_logic.carta27 in game_logic.active_threats):
          print("4 - Assign a scientist to the Time Warp threat")
          check_list.append("4")
        if (game_logic.carta32 in game_logic.active_threats):
          print("5 - Assign a scientist to the Pandemic threat")
          check_list.append("5")
      print()
      print("Select option: ", end="")
      user = input()
      print()
      if game_logic.validate_input(user, check_list, "That option is not available"):
        break
    return user
  
  elif crew_members == "engineer":
    while True:
      check_list = []
      print("You can: ")
      print("0 - Go back")
      check_list.append("0")
      print("1 - Repair the Hull.")
      check_list.append("1")
      if (game_logic.carta35 in game_logic.active_threats):
        print("2 - Assign a engineer to the Comms Offline threat")
        check_list.append("2")
      if (game_logic.carta36 in game_logic.active_threats ):
        print("3 - Assign a engineer to the Robot Uprising threat")
        check_list.append("3")
      print()
      print("Select option: ", end="")
      user = input()
      print()
      if game_logic.validate_input(user, check_list, "That option is not available"):
        break
    return user

def damage_dealed(threat):
  """
  Function that shows the damage dealed to the ship an its shield.
  Creada por: Javier / Álvaro P.
  """
  print()
  print(f'{threat["nombre"]} was activated:')
  damage_to_shield, damage_to_ship = 0, 0 
  if threat["damage"][0] > 0:
    damage_to_ship = threat["damage"][1]
    damage_to_shield += threat["damage"][0]
    if threat["damage"][0] > game_logic.shield:
      print("The shields couldn't resist the attack")
      print(f"The damage to the hull was: {damage_to_ship + (damage_to_shield - game_logic.shield)}")
    else:
      print(f"The damage to the shields is {damage_to_shield}", end="")
      if threat["damage"][1] > 0:
        print(f" and the damage to the hull is {damage_to_ship}")
      else:
        print()
    
  elif threat["damage"][0] == -1 :
    damage_to_shield = game_logic.shield # Shield destroyed
    print("The shield has been destroyed.")
    damage_to_ship = threat["damage"][1]
    print(f"The damage to the hull is {damage_to_ship}")
    
  elif threat["damage"][0] == -2 :
    damage_to_shield = game_logic.shield # Shield destroyed
    print("The shield has been destroyed an it cannot be repared.")
    damage_to_ship = threat["damage"][1]
    print(f"The damage to the hull is {damage_to_ship}")
  
  else:
    if threat["damage"][1] > 0:
      damage_to_ship = threat["damage"][1]
      print(f"The damage to the hull is {damage_to_ship}")
  return damage_to_shield, damage_to_ship

def main_menu():
  """
  Function that displays the menu with every crew dice
  that has been rolled and threats active.
  Returns 0, 6, 7, (according to the menu option) or a
  type of crew member.
  Developed by: Adrián S.
  """
  while True:
    print()
    print("Enter the number at the beginning of the line to select an option:")
    print("0 - End assignment")
    check_list = ["0"]
    if (game_logic.available_crew.count("commander") != 0):
      if (game_logic.carta35 not in game_logic.active_threats):
        print("1 - Commanders:", game_logic.available_crew.count("commander"))
        check_list.append("1")
      else:
        print("Comms Offline threat is active. Commanders cannot be assigned.")
    if (game_logic.available_crew.count("tactical") != 0):
      print("2 - Tacticals:", game_logic.available_crew.count("tactical"))  
      check_list.append("2")
    if (game_logic.available_crew.count("medic") != 0):
      print("3 - Medics", game_logic.available_crew.count("medic"))
      check_list.append("3")
    if (game_logic.available_crew.count("scientist") != 0):
      print("4 - Scientists:", game_logic.available_crew.count("scientist"))
      check_list.append("4")
    if (game_logic.available_crew.count("engineer") != 0):
      if (game_logic.carta30 not in game_logic.active_threats):
        print("5 - Engineers:", game_logic.available_crew.count("engineer"))
        check_list.append("5")
      else:
        print("Panel Explosion threat is active. Engineers cannot be assigned.")
    if len(game_logic.active_threats) != 0:   
      if (len(game_logic.tacticals_assigned) != 0):
        print("6 - Attack (Total damage:", len(game_logic.total_damage), ")")
        check_list.append("6")
    if(len(game_logic.engineers_assigned) != 0):
      print(f"7 - Repair hull (Total HP recovered: {len(game_logic.total_heal)})")
      check_list.append("7")
    print()
    print("*" * 100)
    print()
    print(f"Hull HP: {game_logic.hull}/8")
    if game_logic.carta22 in game_logic.active_threats:
      print("Shieds are deactivated")
    else:
      print(f"Shields HP: {game_logic.shield}/4")
    show_active_threats(game_logic.active_threats)
    print("*" * 100)
    print()
    print("Select an option: ", end="")
    option = input()
    print()
    if game_logic.validate_input(option, check_list, "Your option was not valid, try it again.\n"):
      break
    time.sleep(0.1)
  return option

def commander_change():
  """
  Uses the ability of the commander to change a crew
  die to one of the user's choice.
  Developed by: Adrián S.
  """
  game_logic.available_crew.remove("commander")
  game_logic.return_crew.append("commander")
  while True:
    print("Which crew member do you want to change? (Select using the indicate number): ")
    print()
    check_list =[]
    if (game_logic.available_crew.count("commander") != 0):
      check_list.append("1")
      print("1 - Commanders:", game_logic.available_crew.count("commander"))
    if (game_logic.available_crew.count("tactical") != 0):
      check_list.append("2")
      print("2 - Tacticals:", game_logic.available_crew.count("tactical"))  
    if (game_logic.available_crew.count("medic") != 0):
      check_list.append("3")
      print("3 - Medics", game_logic.available_crew.count("medic"))
    if (game_logic.available_crew.count("scientist") != 0):
      check_list.append("4")
      print("4 - Scientists:", game_logic.available_crew.count("scientist"))
    if (game_logic.available_crew.count("engineer") != 0):
      check_list.append("5")
      print("5 - Engineers:", game_logic.available_crew.count("engineer"))
    if len(check_list) == 0:
      print("No one can be changed.")
      print()
      return None
    print()
    print("Select option: ", end="")
    removed_crew = input()
    print()
    if game_logic.validate_input(removed_crew, check_list, "Your option was not valid, try it again.\n"):
      break
    time.sleep(0.1)
  print()
  while True:
    print("Which crew member do you want to change it to?")
    print()
    print("1 - Commander")
    print("2 - Tactical")
    print("3 - Medic")
    print("4 - Scientist")
    print("5 - Engineer")
    print()
    print("Select an option: ", end="")
    added_crew = input()
    if game_logic.validate_input(added_crew, ["1", "2", "3", "4", "5"], "Your option was not valid, try it again.\n"):
      break
    time.sleep(0.1)
  if removed_crew == "1":
    game_logic.available_crew.remove("commander")
  elif removed_crew == "2":
    game_logic.available_crew.remove("tactical")
  elif removed_crew == "3":
    game_logic.available_crew.remove("medic")
  elif removed_crew == "4":
    game_logic.available_crew.remove("scientist")
  else:
    game_logic.available_crew.remove("engineer")
    
  if added_crew == "1":
    game_logic.available_crew.append("commander")
  elif added_crew == "2":
    game_logic.available_crew.append("tactical")
  elif added_crew == "3":
    game_logic.available_crew.append("medic")
  elif added_crew == "4":
    game_logic.available_crew.append("scientist")
  else:
    game_logic.available_crew.append("engineer")

def attack():
  """
  Function that uses all the tacticals that have been
  assigned to launch an attack.
  Developed by: Adrián S.
  """
  while True:
    external_threats = []
    for threat in game_logic.active_threats:
      if threat["tipo"] == "External":
        external_threats.append(threat)
    show_active_threats(external_threats)
    if game_logic.count_external_threats() == 0:
      print("So no attack.")
      print()
      game_logic.total_damage = []
      return None
    print()
    threat_chosen = input("Type the name of the threat you want to attack: ").lower()
    while not any(threat_chosen == threat["nombre"].lower() for threat in external_threats):
      print("Sorry, the threat you chose does not exist or is not active.")
      threat_chosen = input("Type the name of the threat you want to attack: ").lower()
      
    for threat in game_logic.active_threats:
      if threat_chosen == threat["nombre"].lower():
        if threat["level"] > 0:
          life = threat["life"]
          print(f"The health of {threat_chosen} is {life}.")
          
          while True:
            print("How much damage do you want to do? (Total damage:", len(game_logic.total_damage), "): ", end="")
            damage_chosen = input()
            check_list = []
            for i in range((min(life, len(game_logic.total_damage))) + 1):
              check_list.append(str(i))
            if game_logic.validate_input(damage_chosen, check_list, "You cannot do that damage."):
              break
            
          damage_chosen = int(damage_chosen)
          life -= damage_chosen
          for _ in range(damage_chosen):
            game_logic.total_damage.pop(0)

          print()
          if life <= 0:
            print("The threat", threat_chosen, "has been destroyed.")
            if game_logic.carta10 is threat: 
              damage = 5
              if damage > game_logic.shield:
                damage -= game_logic.shield
                game_logic.shield = 0
                print(f"The shield has been destroyed. {damage} damage has been dealt to the hull.")
                game_logic.hull -= damage
              else:
                game_logic.shield -= damage
                print(f"The shield has been damaged. {damage} damage has been dealt to the shield.")
            game_logic.active_threats.remove(threat)
          else:
            name = threat["nombre"]
            print(f"The threat name has {life} remaining health points.")
            threat["life"] = life
        else:
          print("You cannot attack Solar Winds, it does not have any level.")
        print()
    if len(game_logic.total_damage) == 0:
      print("You cannot attack anymore.")
      print()
      return None
    elif input("Do you want to attack again? (Type yes or no): ").lower() == "no":
      print("\n")
      return None
    print()

def repair_hull():
  """
  Function that repairs the hull of the ship.
  Developed by: Adrián S.
  """
  game_logic.hull += len(game_logic.total_heal)
  if game_logic.hull > 8:
    game_logic.hull = 8
  print(f"The hull has been repaired. Now, it has {game_logic.hull}/8 HP.")
  game_logic.total_heal.clear()

def science_beam():
  """
  Function that fires the Stasis Beam at the
  spent of a scientist.
  Developed by: Adrián S.
  """
  if game_logic.count_external_threats() == 0:
    print("No threats can be blocked.")
    print()
    return None
  game_logic.available_crew.remove("scientist")
  game_logic.return_crew.append("scientist")
  external_threats = []
  for threat in game_logic.active_threats:
    if threat["tipo"] == "External":
      external_threats.append(threat)
  show_active_threats(external_threats)
  print()
  threat_chosen = input("Type the name of the threat you want to block: ").lower()
  while not any(threat_chosen == threat["nombre"].lower() for threat in external_threats):
    print("Sorry, the threat you chose does not exist or is not active.")
    threat_chosen = input("Type the name of the threat you want to block: ").lower()
  for threat in game_logic.active_threats:
    if threat_chosen == threat["nombre"].lower():
      game_logic.active_threats.remove(threat)
      game_logic.stasis_beam.append(threat)

def final_score(turnos, result):
  """
  Save the final score of the game on a file.
  Developed by: Javier
  """
  print()
  
  if result == "lose":
    print(f"You has survived {turnos} turns but you coudn't save the ship.")
    print("Do you want to save your score?")
    print("Yes or No: ", end="")
    choice = input().lower()
    if choice[0] == "y":
        print("What is your name?: ", end="")
        name = input()

        score_file = open("./Datos_de_guardado/score.txt", "a", encoding="utf-8")
        score_file.write(f"{name} has lasted {turnos} turns but couldn't survive.\n")
        score_file.close()
      
        clear_screen()
        print("Old Players:")
        score_file = open("./Datos_de_guardado/score.txt", "r", encoding="utf-8")
        for line in score_file.readlines():
            print(line, end="")
        score_file.close()

    else:
        print("Thanks for playing!")

  elif result == "win":
      print("Do you want to save your score?")
      print("Yes or No: ", end="")
      choice = input().lower()
      if choice[0] == "y":
          print("What is your name?: ", end="")
          name = input()
        
          score_file = open("./Datos_de_guardado/score.txt", "a", encoding="utf-8")
          score_file.write(f"{name} has survived all the threaths in {turnos} turns.\n")
          score_file.close()
          clear_screen()
          print("Old Players")
          score_file = open("./Datos_de_guardado/score.txt", "r", encoding="utf-8")
          for line in score_file.readlines():
              print(line, end="")
          score_file.close()
      else:
        print("Thanks for playing!")
  
def end_assignment():
  """
  Function that asks the user to
  confirm the end of the assignment.
  Developed by: Adrián S.
  """
  while True:
    print("Are you sure you want to end the assignment?")
    print("0- Go back")
    print("1- Yes, end my turn")
    print()
    print("Select an option: ", end="")
    option = input()
    if game_logic.validate_input(option, ["0", "1"], "\nYou may only choose 0 or 1\n"):
      break
  return option

def shields_full():
  '''
  Función que rellena al máximo (4) los escudos.
  Creado por: Álvaro P
  '''
  game_logic.shield = 4
  print("Shields have been repaired.")