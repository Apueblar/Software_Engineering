import random, input_output

def roll_die():
  '''
  Función que simula el tiro de un dado.
  output: numero entero entre 1 y 6
  Creado por: Álvaro P.
  '''
  return random.randint(1,6)

def throw_crew_die():
  '''
  Función que simula el tiro del dado de crew.
  output: dependiendo del dado:
  ["commander", "tactical", "medic", "scientist", "engineer", "threat"]
  Creado por: Álvaro P.
  '''
  die = roll_die()
  if die == 1:
    return "commander"
  if die == 2:
    return "tactical"
  if die == 3:
    return "medic"
  if die == 4:
    return "scientist"
  if die == 5:
    return "engineer"
  return "threat"

def difficulty():
  '''
  Función que actualiza las cartas threat en función de la dificultad.
  Usada solo al iniciar el juego.
  Creado por: Álvaro P.
  '''
  difficulty = input_output.select_difficulty()
  if difficulty == 1: # Easy
    # Remove last do not panic cards
    del possible_threats[-1:]
  if difficulty == 2: # Medium
    # Remove 3 do not panic cards
    del possible_threats[-3:]
  if difficulty == 3: # Hard
    # Remove 6 last cards
    del possible_threats[-6:]

def select_game_mode():
  '''
  Función que dependiendo de la respuesta del usuario reduce la duración del juego o no.
  Creado por: Álvaro P.
  '''
  respuesta = input_output.select_game_mode()
  random.shuffle(possible_threats) # Randomize the list
  # Respuesta 1: Normal game
  if respuesta == 2:
    del possible_threats[-5:]
  elif respuesta == 3:
    del possible_threats[-8:]

def count_external_threats():
  '''
  Función que cuenta el número de threats activos.
  Creado por: Álvaro P.
  '''
  count = 0
  for threat in active_threats:
    if threat["tipo"] == "External":
      count += 1
  return count

def scan_for_threats():
  '''
  Función que busca en la lista threats.
  effect: Quita los threat de la lista crew_members
  Creado por: Álvaro P.
  '''
  while "threat" in available_crew:
    available_crew.remove("threat")
    threats_crew.append("threat")
    input_output.found_a_threat(threats_until_danger - len(threats_crew))
    if len(threats_crew) == threats_until_danger:
        increment_active_threats()
        for i in threats_crew:
            return_crew.append(i)
        del threats_crew[:]

def roll_crew_members():
  '''
  Función que da trabajo a los available_crew members.
  Creado por: Álvaro P.
  '''
  for i in range(len(available_crew)):
    available_crew[i] = throw_crew_die()
  available_crew.sort()

def increment_active_threats():
  '''
  Función que incrementa el numero de threats activos si no son "Don't panic".
  Creado por: Álvaro P.
  '''
  if len(possible_threats) != 0:
    number = random.randint(1 , len(possible_threats)) - 1
    if possible_threats[number]["nombre"] ==  "Don't Panic":
      input_output.dont_panic()
    else: 
      input_output.show_new_threat(possible_threats[number])
      active_threats.append(possible_threats[number])
    del possible_threats[number]
  else:
    input_output.no_threats_left()

def gather_up_crew(return_crew):
  '''
  Función que devuelve returning_crew a available_crew y reinicia returning_crew.
  Creado por: Álvaro P.
  '''
  for crew in return_crew:
    available_crew.append(crew)
  del return_crew[:]

# Possible Threats
carta1  = {"nombre" : "Flagship", "tipo" : "External", "damage" : [3,0] , "level" : 4 , "life" : 4, "activated" : [4,5,6]}
carta2  = {"nombre" : "Solar Winds", "tipo" : "External", "damage" : [5,0] , "level" : 0 , "life" : 0, "activated" : [2]}
carta3  = {"nombre" : "Intercepter", "tipo" : "External", "damage" : [1,0] , "level" : 3 , "life" : 3, "activated" : [1,2,3,4,5]}
carta4  = {"nombre" : "Scouting Ship", "tipo" : "External", "damage" : [1,0] , "level" : 3 , "life" : 3, "activated" : ["if Hull damage"]}
carta5  = {"nombre" : "Raiders 1", "tipo" : "External", "damage" : [0,2] , "level" : 2 , "life" : 2, "special_effect" : "Ignores Shields", "activated" : [4,6]}
carta6  = {"nombre" : "Boarding Ship", "tipo" : "External", "damage" : [2,0] , "level" : 4 , "life" : 4, "special_effect" : "Send a tactical to the infirmary", "activated" : [3,4]}
carta7  = {"nombre" : "Space Pirates 1", "tipo" : "External", "damage" : [2,0] , "level" : 3 , "life" : 3, "activated" : [1,3]}
carta8  = {"nombre" : "Raiders 2", "tipo" : "External", "damage" : [0,2] , "level" : 2 , "life" : 2, "special_effect" : "Ignores Shields", "activated" : [4,6]}
carta9  = {"nombre" : "Raiders 3", "tipo" : "External", "damage" : [0,2] , "level" : 2 , "life" : 2, "special_effect" : "Ignores Shields", "activated" : [1,4]}
carta10 = {"nombre" : "Meteoroid", "tipo" : "External", "damage" : [0,1] , "level" : 4 , "life" : 4, "activated" : [1], "when destroyed" : "5 Damage"}
carta11 = {"nombre" : "Drone 1", "tipo" : "External", "damage" : [1,0] , "level" : 1 , "life" : 1, "activated" : [2,4,6]}
carta12 = {"nombre" : "Bounty Ship", "tipo" : "External", "damage" : [-1,1] , "level" : 4 , "life" : 4, "activated" : [1,2]}
carta13 = {"nombre" : "Bomber 1", "tipo" : "External", "damage" : [1,0] , "level" : 3 , "life" : 3, "special_effect" : "Send a unit to the infirmary", "activated" : [3,4]}
carta14 = {"nombre" : "Space Pirates 2", "tipo" : "External", "damage" : [2,0] , "level" : 2 , "life" : 2, "activated" : [3,6]}
carta15 = {"nombre" : "Intercepter X", "tipo" : "External", "damage" : [1,0] , "level" : 4 , "life" : 4, "activated" : [1,2,3,4,5]}
carta16 = {"nombre" : "Space Pirates 3", "tipo" : "External", "damage" : [2,0] , "level" : 2 , "life" : 2, "activated" : [3,6]}
carta17 = {"nombre" : "Drone 2", "tipo" : "External", "damage" : [1,0] , "level" : 1 , "life" : 1, "activated" : [3,5]}
carta18 = {"nombre" : "Hijackers", "tipo" : "External", "damage" : [2,0] , "level" : 4 , "life" : 4, "activated" : [4,5], "counter" : [2, "commander"]}
carta19 = {"nombre" : "Corsair", "tipo" : "External", "damage" : [2,0] , "level" : 2 , "life" : 2, "activated" : [4,5,6]}
carta20 = {"nombre" : "Friendly Fire", "tipo" : "Internal", "effect" : "All tactical go to infirmary", "level" : 0}
carta21 = {"nombre" : "Cosmic Existentialism", "tipo" : "Internal", "effect" : "You must add a scientist before assigning any other", "counter" : [1, "scientist"]}
carta22 = {"nombre" : "Nebula", "tipo" : "External", "damage" : [-2,1] , "level" : 3 , "life" : 3, "activated" : [1,2,3,4,5], "when destroyed" : "Shields Online"}
carta23 = {"nombre" : "Mercenary", "tipo" : "External", "damage" : [2,0] , "level" : 3 , "life" : 3, "activated" : ["if not threats activated"]}
carta24 = {"nombre" : "Cloaked Threats", "tipo" : "Internal", "effect" : "Roll the threat die again", "activated" : [2] ,"counter" : [1, "scientist", 1, "commander"]}
carta25 = {"nombre" : "Assault Cruiser 1", "tipo" : "External", "damage" : [2,0] , "level" : 4 , "life" : 4, "activated" : [4,5]}
carta26 = {"nombre" : "Distracted", "tipo" : "Internal", "activated" : [3,4] , "initial" : "Takes a crew member", "effect" : "Returns the member", "counter" : [2,"medic"]}
carta27 = {"nombre" : "Time Warp", "tipo" : "Internal", "activated" : [2], "effect" : "All threats recover 1 damage", "counter" : [2, "scientist"]}
carta28 = {"nombre" : "Bomber 2", "tipo" : "External", "damage" : [2,0] , "level" : 2 , "life" : 2, "special_effect" : "Send a unit to the infirmary", "activated" : [2,4]}
carta29 = {"nombre" : "Boost Morale", "tipo" : "Internal", "activated" : [6], "effect" : "Return a Threat Detected", "level" : 0}
carta30 = {"nombre" : "Panel Explosion", "tipo" : "Internal", "effect" : "You can't assign engineers", "counter" : [1, "medic"]}
carta31 = {"nombre" : "Assault Cruiser 2", "tipo" : "External", "damage" : [2,0] , "level" : 4 , "life" : 4, "activated" : [1,2]}
carta32 = {"nombre" : "Pandemic", "tipo" : "Internal", "activated" : [1], "effect" : "Send a unit to the infirmary", "counter" : [[1, "scientist"], [1, "medic"]]}
carta33 = {"nombre" : "Invaders", "tipo" : "Internal", "activated" : [2,4], "effect" : "Send a unit to the infirmary", "counter" : [2, "tactical"]} 
carta34 = {"nombre" : "Bomber 3", "tipo" : "External", "damage" : [1,0] , "level" : 2 , "life" : 2, "special_effect" : "Send a unit to the infirmary", "activated" : [2,4]}
carta35 = {"nombre" : "Comms Offline", "tipo" : "Internal", "effect" : "You can't assign commanders", "counter" : [1,"engineer"]}
carta36 = {"nombre" : "Robot Uprising", "tipo" : "Internal", "activated" : [1,2,3], "effect" : "Send a unit to the infirmary", "counter" : [1, "engineer"]}
carta_dont_panic1 = {"nombre" : "Don't Panic", "tipo" : "Internal", "effect" : "Nothing Happens."}
carta_dont_panic2 = {"nombre" : "Don't Panic", "tipo" : "Internal", "effect" : "Nothing Happens."}
carta_dont_panic3 = {"nombre" : "Don't Panic", "tipo" : "Internal", "effect" : "Nothing Happens."}
carta_dont_panic4 = {"nombre" : "Don't Panic", "tipo" : "Internal", "effect" : "Nothing Happens."}
carta_dont_panic5 = {"nombre" : "Don't Panic", "tipo" : "Internal", "effect" : "Nothing Happens."}
carta_dont_panic6 = {"nombre" : "Don't Panic", "tipo" : "Internal", "effect" : "Nothing Happens."}

possible_threats = [carta1, carta2, carta3, carta4, carta5, carta6, carta7, carta8, carta9, carta10, carta11, carta12, carta13, carta14, carta15, carta16, carta17, carta18, carta19, carta20, carta21, carta22, carta23, carta24, carta25, carta26, carta27, carta28, carta29, carta30, carta31, carta32, carta33, carta34, carta35, carta36, carta_dont_panic1, carta_dont_panic2, carta_dont_panic3, carta_dont_panic4, carta_dont_panic5, carta_dont_panic6]

hull = 8 # Initail health of the hull, if it reaches 0, the ship is destroyed
shield = 4 # Initial state of the shields, if it rewill be reaches 0, the damage will be recived by the ship
threats_until_danger = 3 # Number of threats until a new threat is activated
active_threats = []
initial_available_crew = 6 # Number of crew members available at the beginning of the game.
available_crew = []
for i in range(initial_available_crew):
  available_crew.append(str(i)) # Lista con crew available
infirmary = [] # List with crew in the infirmary
return_crew = [] # List with crew that return being available available
threats_crew = [] # List with crew that are in threats
stasis_beam = [] # List of available threats bloked by the scientist
hijackers = [] # List used to store the two commanders needed to counter this threat 
cloaked_threats = [] # List that used to store the scientific and the commanders needed to counter this threat 
invaders = [] # List used to store the two tacticals needed to counter this threat 
distracted_crew = [] # List that stores all the crew members that have been affected by the distracted threat
distracted_disable = [] # List that used to store the two medics needed to counter this threat 
time_warp = [] # List that used to store the two scientifics needed to counter this threat
tacticals_assigned = [] # List that stores the quantity of tacticals that have been assigned in order to attack 
total_damage = [] # List that stores the different quantities of damage that are going to affect the ship 
engineers_assigned = [] # List that stores the quantity of engineers that have been assigned in order to attack
total_heal = [] # List that stores the different quantities of healing that are going to affect the hull

def activate_threat(shield, hull):
  """
  Activa un threat segun el valor de la tirada.
  Creado por: Javier
  """
  dado = roll_die()
  print(f"The die was {dado}\n")
  activated = 0
  damage_to_shield, damage_to_ship = 0, 0
  d_s, d_h = 0, 0
  
  for threat in active_threats[:]:
    
    if threat["tipo"] == "External" and dado in threat["activated"]:
      activated += 1
      d_s, d_h = input_output.damage_dealed(threat)
      damage_to_shield += d_s
      damage_to_ship += d_h
      if threat["level"] == 0:
         active_threats.remove(threat)
    if threat["tipo"] == "Internal" and "activated" in threat and dado in threat["activated"]:
      activated += 1
      if threat == carta26:
        if len(distracted_crew) > 0:
          return_crew.append(distracted_crew[0])
          distracted_crew.clear()
        active_threats.remove(carta26)
      if threat == carta27:
        for threat in active_threats:
          if threat["type"] == "External" and threat["life"] < threat["level"]:
            threat["life"] += 1
      if threat == carta29:
        discard_threat()
      if threat == carta32:
        send_to_infirmary()
      if threat == carta33: 
        send_to_infirmary()
      if threat == carta36:
        send_to_infirmary()
      
  if (carta4 in active_threats) and (damage_to_shield > 0 or damage_to_ship > 0):
      # Se activa si ha recibido daño el hull
      # Cumple los requisitos
      d_s, d_h = input_output.damage_dealed(carta4)
      damage_to_shield += d_s
      damage_to_ship += d_h
  
  if (carta23 in active_threats) and (activated == 0):  
    # Se activa si no se activó ningún threat    
    d_s, d_h = input_output.damage_dealed(carta23)
    damage_to_shield += d_s
    damage_to_ship += d_h
  
  if damage_to_shield > shield:
    damage_to_shield -= shield
    shield = 0
    damage_to_ship += damage_to_shield
    hull -= damage_to_ship
  else:
    shield -= damage_to_shield
    hull -= damage_to_ship
  
  return shield, hull, dado

def send_to_infirmary():
  """
  Send a random member of the crew to the infirmary
  Created by: Javier
  """
  # The list return_crew contains all the available crew for the next round.
  # The list infirmary contains all the crew in the infirmary.
  if len(return_crew) > 0:
    ill = random.randint(0, len(return_crew) - 1)
    infirmary.append(return_crew[ill])
    return_crew.pop(ill)
  else:
    ill = random.randint(0, len(available_crew) - 1)
    infirmary.append(available_crew[ill])
    available_crew.pop(ill)
  print("A crew member was sent to the infirmary")

def discard_threat():
  """
  Discards one of the threat die that are in the scanner.
  Created by: Adrián S.
  """
  threats_crew.remove("threat")
  return_crew.append("threat")

def validate_input(input, param_list, error_message):
  """
  Checks if the input of the users is valid or not.
  Prints a message with an error if it is not valid
  Returns true if it is valid. Otherwise, false.
  Developed by: Adrián S.
  """
  if input not in param_list:
    print(error_message)
    return False
  return True

def commander_reroll():
  """
  Function that allows the user to re-roll
  all crew dice at the spent of a commander.
  Developed by: Adrián S.
  """
  available_crew.remove("commander")
  return_crew.append("commander")
  roll_crew_members()
  scan_for_threats()

def tactical_assignment():
  """
  Function that assigns a single tactical to perform
  an attack.
  Developed by: Adrián S.
  """
  available_crew.remove("tactical")
  return_crew.append("tactical")
  if len(tacticals_assigned) == 0:
    total_damage.append("Ah")
  else:
    for _ in range(2):
      total_damage.append("Ah")
  tacticals_assigned.append("tactical")

def medical_infirmary():
  """
  Function that returns all crew members from the
  infirmary so they can be used in following turns
  at the spent of a medical.
  Developed by: Adrián S.
  """
  available_crew.remove("medic")
  return_crew.append("medic")
  for crew in infirmary:
    return_crew.append(crew)
  infirmary.clear()

def medical_scanners():
  """
  Function that takes a die from the scanners
  so it can be used in following turns at the
  spent of a medical.
  Developed by: Adrián S.
  """
  available_crew.remove("medic")
  return_crew.append("medic")
  discard_threat()

def science_shields():
  """
  Function that restores the shields to full
  at the spent of a scientist.
  Developed by: Adrián S.
  """
  available_crew.remove("scientist")
  return_crew.append("scientist")
  input_output.shields_full()

def engineer_assignment():
  """
  Function that assigns a single engineer to
  repair the hull.
  Developed by: Adrián S.
  """
  available_crew.remove("engineer")
  return_crew.append("engineer")
  if len(engineers_assigned) == 0:
    total_heal.append("Ah")
  else:
    for _ in range(2):
      total_heal.append("Ah")
  engineers_assigned.append("engineer")

def commander_hijackers():
  """
  Function that assigns a commander to the
  Hijackers threat.
  Developed by: Adrián S.
  """
  available_crew.remove("commander")
  hijackers.append("commander")
  if len(hijackers) == 2:
    for _ in range(len(hijackers)):
      return_crew.append("commander")
    active_threats.remove(carta18)
    hijackers.clear()

def commander_cloaked_threats():
  """
  Function that assigns a commander to the
  Cloaked Threats threat.
  Developed by: Adrián S.
  """
  available_crew.remove("commander")
  cloaked_threats.append("commander")
  # The commander remains in cloaked_threats until a scientist is assigned.
  if len(cloaked_threats) == 2:
    # Eliminates the threat and returns all to normality.
    return_crew.append("commander")
    return_crew.append("scientist")
    active_threats.remove(carta24)
    cloaked_threats.clear()

def tactical_invaders():
  """
  Function that assigns a tactical to the
  Invaders threat.
  Developed by: Adrián S.
  """
  available_crew.remove("tactical")
  invaders.append("tactical")
  # The tactical remains in invaders until another tactical is assigned.
  if len(invaders) == 2:
    # Eliminates the threat and returns all to normality.
    for _ in range(len(invaders)):
      return_crew.append("tactical")
    active_threats.remove(carta33)
    invaders.clear()

def medical_distracted():
  """
  Function that assigns a medical to the
  Distacted threat.
  Developed by: Adrián S.
  """
  available_crew.remove("medic")
  distracted_disable.append("medic")
  if len(distracted_disable) == 2:
    for _ in range(len(distracted_disable)):
      return_crew.append("medic")
    active_threats.remove(carta26)
    distracted_disable.clear()

def medical_panel_explosion():
  """
  Function that assigns a medical to the
  Panel Explosion threat.
  Developed by: Adrián S.
  """
  available_crew.remove("medic")
  return_crew.append("medic")
  active_threats.remove(carta30)

def medical_pandemic():
  """
  Function that assigns a medical to the
  Pandemic threat.
  Developed by: Adrián S.
  """
  available_crew.remove("medic")
  return_crew.append("medic")
  active_threats.remove(carta32)

def scientist_cosmic_existencialism():
  """
  Function that assigns a scientist to the
  Cosmic Existencialism threat.
  Developed by: Adrián S.
  """
  available_crew.remove("scientist")
  return_crew.append("scientist")
  active_threats.remove(carta21)
  

def scientist_cloaked_threats():
  """
  Function that assigns a scientist to the
  Cloaked Threats threat.
  Developed by: Adrián S.
  """
  available_crew.remove("scientist")
  cloaked_threats.append("scientist")
  if len(cloaked_threats) == 2:
    return_crew.append("commander")
    return_crew.append("scientist")
    active_threats.remove(carta24)
    cloaked_threats.clear()

def scientist_time_warp():
  """
  Function that assigns a scientist to the
  Time Warp threat.
  Developed by: Adrián S.
  """
  available_crew.remove("scientist")
  time_warp.append("scientist")
  if len(time_warp) == 2:
    for _ in range(len(time_warp)):
      return_crew.append("scientist")
    active_threats.remove(carta27)
    time_warp.clear()


def scientist_pandemic():
  """
  Function that assigns a scientist to the
  Pandemic threat.
  Developed by: Adrián S.
  """
  available_crew.remove("scientist")
  return_crew.append("scientist")
  active_threats.remove(carta32)

def engineer_comms_offline():
  """
  Function that assigns an engineer to the
  Comms Offline threat.
  Developed by: Adrián S.
  """
  available_crew.remove("engineer")
  return_crew.append("engineer")
  active_threats.remove(carta35)

def engineer_robot_uprising():
  """
  Function that assigns an engineer to the
  Robot Uprising threat.
  Developed by: Adrián S.
  """
  available_crew.remove("engineer")
  return_crew.append("engineer")
  active_threats.remove(carta36)

def ability_activation(crew, ability):
  """
  Function that, given a crew member and a selected
  ability, executes that ability.
  Developed by: Adrián S.
  """
  if crew == "commander":
    if ability == "1":
      input_output.commander_change()
    elif ability == "2":
      commander_reroll()
    elif ability == "3":
      commander_hijackers()
    else:
      commander_cloaked_threats() 
      
  elif crew == "tactical":
    if ability == "1":
      tactical_assignment()
    else:
      tactical_invaders()

  elif crew == "medic":
    if ability == "1":
      medical_infirmary()
    elif ability == "2":
      medical_scanners()
    elif ability == "3":
      medical_distracted()
    elif ability == "4":
      medical_panel_explosion()
    else:
      medical_pandemic() 
    
  elif crew == "scientist":
    if carta21 in active_threats:
        scientist_cosmic_existencialism()
    else:
      if ability == "1":
        science_shields()
      elif ability == "2":
        input_output.science_beam()
      elif ability == "3":
        scientist_cloaked_threats()
      elif ability == "4":
        scientist_time_warp()
      else:
        scientist_pandemic() 
  
  else: #Engineer
    if ability == "1":
      engineer_assignment()
    elif ability == "2":
      engineer_comms_offline()
    else:
      engineer_robot_uprising()

def number_into_crew(number):
  """
  Function that changes a given number to a crew member,
  Developed by: Adrián S.
  """
  crew = number
  if number == "1":
    crew = "commander"
  if number == "2":
    crew = "tactical"
  if number == "3":
    crew = "medic"
  if number == "4":
    crew = "scientist"
  if number == "5":
    crew = "engineer"
  return crew