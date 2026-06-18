# -*- coding: utf-8 -*-
"""Generate lib/l10n/exercise_names.dart from the catalog + the translation
table below. English is read from assets/catalog/exercises.json (source of
truth); fr/es/de/pt live here. Run:  python tool/generate_exercise_names.py
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATALOG = os.path.join(ROOT, "assets", "catalog", "exercises.json")
OUT = os.path.join(ROOT, "lib", "l10n", "exercise_names.dart")

# id -> (fr, es, de, pt)
T = {
    # ---- Barbell -----------------------------------------------------------
    "bench-press": ("Développé couché", "Press de banca", "Bankdrücken", "Supino"),
    "squat": ("Squat", "Sentadilla", "Kniebeuge", "Agachamento"),
    "deadlift": ("Soulevé de terre", "Peso muerto", "Kreuzheben", "Levantamento terra"),
    "overhead-press": ("Développé épaules (debout)", "Press de hombros (de pie)", "Schulterdrücken (stehend)", "Desenvolvimento de ombros (em pé)"),
    "barbell-row": ("Rowing barre buste penché", "Remo con barra", "Langhantelrudern vorgebeugt", "Remada curvada com barra"),
    "barbell-curl": ("Curl à la barre", "Curl con barra", "Langhantel-Curl", "Rosca direta com barra"),
    "incline-bench-press": ("Développé incliné", "Press inclinado", "Schrägbankdrücken", "Supino inclinado"),
    "decline-bench": ("Développé décliné", "Press declinado", "Negativ-Bankdrücken", "Supino declinado"),
    "close-grip-bench": ("Développé couché prise serrée", "Press cerrado", "Enges Bankdrücken", "Supino fechado"),
    "floor-press": ("Développé au sol", "Press en el suelo", "Floor Press", "Supino no chão"),
    "pin-press": ("Développé sur pins", "Press en pines", "Pin Press", "Supino nos pinos"),
    "front-squat": ("Squat avant", "Sentadilla frontal", "Frontkniebeuge", "Agachamento frontal"),
    "box-squat": ("Box squat", "Sentadilla en cajón", "Box-Kniebeuge", "Agachamento no caixote"),
    "zercher-squat": ("Squat Zercher", "Sentadilla Zercher", "Zercher-Kniebeuge", "Agachamento Zercher"),
    "overhead-squat": ("Squat overhead", "Sentadilla por encima de la cabeza", "Überkopfkniebeuge", "Agachamento overhead"),
    "hex-bar-deadlift": ("Soulevé de terre à la barre hexagonale", "Peso muerto con barra hexagonal", "Kreuzheben mit Trap Bar", "Levantamento terra com barra hexagonal"),
    "sumo-deadlift": ("Soulevé de terre sumo", "Peso muerto sumo", "Sumo-Kreuzheben", "Levantamento terra sumô"),
    "romanian-deadlift": ("Soulevé de terre roumain", "Peso muerto rumano", "Rumänisches Kreuzheben", "Levantamento terra romeno"),
    "stiff-leg-deadlift": ("Soulevé de terre jambes tendues", "Peso muerto con piernas rígidas", "Kreuzheben mit gestreckten Beinen", "Levantamento terra com pernas rígidas"),
    "rack-pull": ("Rack pull", "Rack pull (tirón en rack)", "Rack Pull", "Rack pull"),
    "deficit-deadlift": ("Soulevé de terre en déficit", "Peso muerto con déficit", "Defizit-Kreuzheben", "Levantamento terra com déficit"),
    "snatch-grip-deadlift": ("Soulevé de terre prise d'arraché", "Peso muerto con agarre de arrancada", "Kreuzheben im Reißgriff", "Levantamento terra com pegada de arranco"),
    "good-morning": ("Good morning", "Buenos días (good morning)", "Good Morning", "Good morning (bom dia)"),
    "hip-thrust": ("Hip thrust", "Empuje de cadera", "Hip Thrust", "Elevação de quadril"),
    "barbell-lunge": ("Fente à la barre", "Zancada con barra", "Ausfallschritt mit Langhantel", "Afundo com barra"),
    "barbell-split-squat": ("Squat fendu à la barre", "Sentadilla dividida con barra", "Split Squat mit Langhantel", "Agachamento split com barra"),
    "barbell-step-up": ("Montée sur banc à la barre", "Subida al cajón con barra", "Step-up mit Langhantel", "Subida no caixote com barra"),
    "barbell-calf-raise": ("Extension des mollets à la barre", "Elevación de gemelos con barra", "Wadenheben mit Langhantel", "Elevação de panturrilha com barra"),
    "military-press": ("Développé militaire", "Press militar", "Military Press", "Desenvolvimento militar"),
    "push-press": ("Push press", "Push press", "Push Press", "Push press"),
    "behind-neck-press": ("Développé nuque", "Press tras nuca", "Nackendrücken", "Desenvolvimento por trás da nuca"),
    "landmine-press": ("Développé landmine", "Press landmine", "Landmine-Drücken", "Desenvolvimento landmine"),
    "landmine-row": ("Rowing landmine", "Remo landmine", "Landmine-Rudern", "Remada landmine"),
    "pendlay-row": ("Rowing Pendlay", "Remo Pendlay", "Pendlay-Rudern", "Remada Pendlay"),
    "yates-row": ("Rowing Yates", "Remo Yates", "Yates-Rudern", "Remada Yates"),
    "t-bar-row": ("Rowing T-bar", "Remo en T", "T-Bar-Rudern", "Remada cavalinho"),
    "barbell-upright-row": ("Rowing menton à la barre", "Remo al mentón con barra", "Aufrechtes Rudern mit Langhantel", "Remada alta com barra"),
    "barbell-shrug": ("Haussement d'épaules à la barre", "Encogimiento con barra", "Schulterheben mit Langhantel", "Encolhimento com barra"),
    "high-pull": ("Tirage haut à la barre", "Tirón alto con barra", "High Pull mit Langhantel", "Puxada alta com barra"),
    "power-clean": ("Épaulé (power clean)", "Cargada de potencia", "Power Clean", "Power clean"),
    "clean-and-jerk": ("Épaulé-jeté", "Cargada y envión", "Umsetzen und Stoßen", "Arremesso (clean and jerk)"),
    "snatch": ("Arraché", "Arrancada", "Reißen", "Arranco"),
    "thruster": ("Thruster à la barre", "Thruster con barra", "Thruster mit Langhantel", "Thruster com barra"),
    "ez-bar-curl": ("Curl à la barre EZ", "Curl con barra Z", "Curl mit SZ-Stange", "Rosca com barra W"),
    "preacher-curl": ("Curl au pupitre", "Curl predicador", "Scott-Curl", "Rosca Scott"),
    "spider-curl": ("Spider curl", "Curl araña", "Spider-Curl", "Rosca aranha"),
    "drag-curl": ("Drag curl", "Curl de arrastre", "Drag-Curl", "Rosca de arrasto"),
    "reverse-curl": ("Curl inversé", "Curl invertido", "Reverse-Curl", "Rosca inversa"),
    "skull-crusher": ("Barre au front", "Press francés", "Stirndrücken", "Tríceps testa"),
    "jm-press": ("JM press", "JM press", "JM Press", "JM press"),
    "barbell-wrist-curl": ("Curl des poignets à la barre", "Curl de muñeca con barra", "Handgelenk-Curl mit Langhantel", "Rosca de punho com barra"),
    # ---- Dumbbell ----------------------------------------------------------
    "db-bench-press": ("Développé couché aux haltères", "Press de banca con mancuernas", "Kurzhantel-Bankdrücken", "Supino com halteres"),
    "incline-db-press": ("Développé incliné aux haltères", "Press inclinado con mancuernas", "Schrägbankdrücken mit Kurzhanteln", "Supino inclinado com halteres"),
    "decline-db-press": ("Développé décliné aux haltères", "Press declinado con mancuernas", "Negativ-Bankdrücken mit Kurzhanteln", "Supino declinado com halteres"),
    "db-shoulder-press": ("Développé épaules aux haltères", "Press de hombros con mancuernas", "Schulterdrücken mit Kurzhanteln", "Desenvolvimento de ombros com halteres"),
    "arnold-press": ("Développé Arnold", "Press Arnold", "Arnold-Drücken", "Desenvolvimento Arnold"),
    "db-lateral-raise": ("Élévations latérales aux haltères", "Elevaciones laterales con mancuernas", "Seitheben mit Kurzhanteln", "Elevação lateral com halteres"),
    "db-front-raise": ("Élévations frontales aux haltères", "Elevaciones frontales con mancuernas", "Frontheben mit Kurzhanteln", "Elevação frontal com halteres"),
    "db-rear-delt-fly": ("Oiseau aux haltères", "Pájaros con mancuernas", "Reverse Flys mit Kurzhanteln", "Crucifixo inverso com halteres"),
    "db-row": ("Rowing à un bras aux haltères", "Remo con mancuerna", "Kurzhantelrudern", "Remada com halter"),
    "db-pullover": ("Pull-over aux haltères", "Pullover con mancuerna", "Überzüge mit Kurzhantel", "Pullover com halter"),
    "db-fly": ("Écarté aux haltères", "Aperturas con mancuernas", "Fliegende mit Kurzhanteln", "Crucifixo com halteres"),
    "db-curl": ("Curl aux haltères", "Curl con mancuernas", "Kurzhantel-Curl", "Rosca com halteres"),
    "hammer-curl": ("Curl marteau", "Curl martillo", "Hammer-Curl", "Rosca martelo"),
    "db-incline-curl": ("Curl incliné aux haltères", "Curl inclinado con mancuernas", "Schrägbank-Curl mit Kurzhanteln", "Rosca inclinada com halteres"),
    "db-concentration-curl": ("Curl concentration", "Curl de concentración", "Konzentrations-Curl", "Rosca concentrada"),
    "zottman-curl": ("Curl Zottman", "Curl Zottman", "Zottman-Curl", "Rosca Zottman"),
    "db-preacher-curl": ("Curl au pupitre aux haltères", "Curl predicador con mancuerna", "Scott-Curl mit Kurzhantel", "Rosca Scott com halter"),
    "db-overhead-extension": ("Extension triceps au-dessus de la tête", "Extensión de tríceps por encima de la cabeza", "Trizepsdrücken über Kopf mit Kurzhantel", "Extensão de tríceps acima da cabeça"),
    "db-skull-crusher": ("Barre au front aux haltères", "Press francés con mancuernas", "Stirndrücken mit Kurzhanteln", "Tríceps testa com halteres"),
    "db-tricep-kickback": ("Kickback triceps aux haltères", "Patada de tríceps con mancuerna", "Trizeps-Kickback mit Kurzhantel", "Tríceps coice com halter"),
    "goblet-squat": ("Goblet squat", "Sentadilla goblet", "Goblet-Kniebeuge", "Agachamento goblet"),
    "db-bulgarian-split-squat": ("Squat bulgare", "Sentadilla búlgara", "Bulgarische Split-Kniebeuge", "Agachamento búlgaro"),
    "db-lunge": ("Fente aux haltères", "Zancada con mancuernas", "Ausfallschritt mit Kurzhanteln", "Afundo com halteres"),
    "db-step-up": ("Montée sur banc aux haltères", "Subida al cajón con mancuernas", "Step-up mit Kurzhanteln", "Subida no caixote com halteres"),
    "db-romanian-deadlift": ("Soulevé de terre roumain aux haltères", "Peso muerto rumano con mancuernas", "Rumänisches Kreuzheben mit Kurzhanteln", "Levantamento terra romeno com halteres"),
    "db-deadlift": ("Soulevé de terre aux haltères", "Peso muerto con mancuernas", "Kreuzheben mit Kurzhanteln", "Levantamento terra com halteres"),
    "db-calf-raise": ("Extension des mollets aux haltères", "Elevación de gemelos con mancuernas", "Wadenheben mit Kurzhanteln", "Elevação de panturrilha com halteres"),
    "db-shrug": ("Haussement d'épaules aux haltères", "Encogimiento con mancuernas", "Schulterheben mit Kurzhanteln", "Encolhimento com halteres"),
    "db-upright-row": ("Rowing menton aux haltères", "Remo al mentón con mancuernas", "Aufrechtes Rudern mit Kurzhanteln", "Remada alta com halteres"),
    "db-thruster": ("Thruster aux haltères", "Thruster con mancuernas", "Thruster mit Kurzhanteln", "Thruster com halteres"),
    "db-renegade-row": ("Renegade row", "Remo renegado", "Renegade Row", "Remada renegada"),
    "db-side-bend": ("Flexion latérale aux haltères", "Flexión lateral con mancuerna", "Seitneigen mit Kurzhantel", "Flexão lateral com halter"),
    "db-wrist-curl": ("Curl des poignets aux haltères", "Curl de muñeca con mancuernas", "Handgelenk-Curl mit Kurzhanteln", "Rosca de punho com halteres"),
    # ---- Kettlebell --------------------------------------------------------
    "kettlebell-swing": ("Swing kettlebell", "Swing con pesa rusa", "Kettlebell-Swing", "Swing com kettlebell"),
    "kettlebell-goblet-squat": ("Goblet squat kettlebell", "Sentadilla goblet con pesa rusa", "Goblet-Kniebeuge mit Kettlebell", "Agachamento goblet com kettlebell"),
    "kettlebell-front-squat": ("Squat avant kettlebell", "Sentadilla frontal con pesa rusa", "Frontkniebeuge mit Kettlebell", "Agachamento frontal com kettlebell"),
    "kettlebell-deadlift": ("Soulevé de terre kettlebell", "Peso muerto con pesa rusa", "Kreuzheben mit Kettlebell", "Levantamento terra com kettlebell"),
    "kettlebell-clean": ("Épaulé kettlebell", "Cargada con pesa rusa", "Kettlebell Clean", "Clean com kettlebell"),
    "kettlebell-snatch": ("Arraché kettlebell", "Arrancada con pesa rusa", "Kettlebell Snatch", "Arranco com kettlebell"),
    "kettlebell-press": ("Développé kettlebell", "Press con pesa rusa", "Kettlebell-Drücken", "Desenvolvimento com kettlebell"),
    "kettlebell-row": ("Rowing kettlebell", "Remo con pesa rusa", "Kettlebell-Rudern", "Remada com kettlebell"),
    "kettlebell-lunge": ("Fente kettlebell", "Zancada con pesa rusa", "Ausfallschritt mit Kettlebell", "Afundo com kettlebell"),
    "kettlebell-thruster": ("Thruster kettlebell", "Thruster con pesa rusa", "Thruster mit Kettlebell", "Thruster com kettlebell"),
    "turkish-get-up": ("Relevé turc", "Levantamiento turco", "Türkisch Aufstehen", "Levantamento turco"),
    # ---- Machine -----------------------------------------------------------
    "leg-press": ("Presse à cuisses (chariot)", "Prensa de piernas (trineo)", "Beinpresse (Schlitten)", "Leg press (trenó)"),
    "leg-press-horizontal": ("Presse à cuisses (horizontale)", "Prensa de piernas (horizontal)", "Beinpresse (horizontal)", "Leg press (horizontal)"),
    "vertical-leg-press": ("Presse à cuisses verticale", "Prensa de piernas vertical", "Vertikale Beinpresse", "Leg press vertical"),
    "hack-squat": ("Hack squat", "Sentadilla hack", "Hackenschmidt-Kniebeuge", "Agachamento hack"),
    "smith-squat": ("Squat à la machine Smith", "Sentadilla en máquina Smith", "Kniebeuge an der Multipresse", "Agachamento no Smith"),
    "smith-bench-press": ("Développé couché à la Smith", "Press de banca en máquina Smith", "Bankdrücken an der Multipresse", "Supino no Smith"),
    "smith-shoulder-press": ("Développé épaules à la Smith", "Press de hombros en máquina Smith", "Schulterdrücken an der Multipresse", "Desenvolvimento de ombros no Smith"),
    "smith-row": ("Rowing à la Smith", "Remo en máquina Smith", "Rudern an der Multipresse", "Remada no Smith"),
    "leg-extension": ("Extension des jambes (leg extension)", "Extensión de cuádriceps", "Beinstrecker", "Cadeira extensora"),
    "seated-leg-curl": ("Leg curl assis", "Curl femoral sentado", "Beinbeuger sitzend", "Mesa flexora sentado"),
    "lying-leg-curl": ("Leg curl allongé", "Curl femoral tumbado", "Beinbeuger liegend", "Mesa flexora deitado"),
    "calf-raise": ("Extension des mollets debout", "Elevación de gemelos de pie", "Wadenheben stehend", "Elevação de panturrilha em pé"),
    "seated-calf-raise": ("Extension des mollets assis", "Elevación de gemelos sentado", "Wadenheben sitzend", "Elevação de panturrilha sentado"),
    "hip-adduction": ("Adduction de hanche", "Aducción de cadera", "Adduktoren-Maschine", "Adução de quadril"),
    "hip-abduction": ("Abduction de hanche", "Abducción de cadera", "Abduktoren-Maschine", "Abdução de quadril"),
    "glute-kickback-machine": ("Kickback fessier (machine)", "Patada de glúteo (máquina)", "Glute Kickback (Maschine)", "Coice de glúteo (máquina)"),
    "chest-press": ("Développé pectoraux à la machine", "Press de pecho en máquina", "Brustpresse (Maschine)", "Supino na máquina"),
    "machine-chest-fly": ("Pec deck (écarté machine)", "Aperturas en pec deck", "Butterfly (Pec Deck)", "Voador (pec deck)"),
    "machine-shoulder-press": ("Développé épaules à la machine", "Press de hombros en máquina", "Schulterpresse (Maschine)", "Desenvolvimento de ombros na máquina"),
    "machine-lateral-raise": ("Élévations latérales à la machine", "Elevaciones laterales en máquina", "Seitheben (Maschine)", "Elevação lateral na máquina"),
    "machine-rear-delt-fly": ("Oiseau à la machine", "Pájaros en máquina", "Reverse Butterfly (Maschine)", "Crucifixo inverso na máquina"),
    "machine-row": ("Rowing à la machine", "Remo en máquina", "Rudern (Maschine)", "Remada na máquina"),
    "machine-bicep-curl": ("Curl biceps à la machine", "Curl de bíceps en máquina", "Bizeps-Curl (Maschine)", "Rosca de bíceps na máquina"),
    "machine-preacher-curl": ("Curl au pupitre à la machine", "Curl predicador en máquina", "Scott-Curl (Maschine)", "Rosca Scott na máquina"),
    "machine-tricep-extension": ("Extension triceps à la machine", "Extensión de tríceps en máquina", "Trizepsstrecker (Maschine)", "Extensão de tríceps na máquina"),
    "machine-dip": ("Dips à la machine", "Fondos en máquina", "Dips (Maschine)", "Mergulho na máquina"),
    "machine-ab-crunch": ("Crunch abdominaux à la machine", "Crunch abdominal en máquina", "Bauchmaschine (Crunch)", "Abdominal na máquina"),
    "machine-back-extension": ("Extension lombaire (machine)", "Extensión lumbar (máquina)", "Rückenstrecker (Maschine)", "Extensão lombar (máquina)"),
    # ---- Cable -------------------------------------------------------------
    "lat-pulldown": ("Tirage vertical (poulie haute)", "Jalón al pecho", "Latzug", "Puxada alta (pulley)"),
    "close-grip-pulldown": ("Tirage vertical prise serrée", "Jalón con agarre cerrado", "Latzug enger Griff", "Puxada com pegada fechada"),
    "straight-arm-pulldown": ("Tirage bras tendus à la poulie", "Jalón con brazos rectos", "Überzug am Kabel (gestreckte Arme)", "Puxada com braços estendidos"),
    "seated-cable-row": ("Rowing assis à la poulie", "Remo sentado en polea", "Rudern sitzend am Kabel", "Remada sentada no pulley"),
    "single-arm-cable-row": ("Rowing à un bras à la poulie", "Remo a una mano en polea", "Einarmiges Kabelrudern", "Remada unilateral no pulley"),
    "face-pull": ("Face pull (tirage visage)", "Face pull (tirón a la cara)", "Face Pull", "Face pull (puxada para o rosto)"),
    "cable-rear-delt-fly": ("Oiseau à la poulie", "Pájaros en polea", "Reverse Flys am Kabel", "Crucifixo inverso no cabo"),
    "cable-fly": ("Écarté à la poulie (crossover)", "Aperturas en polea (cruce)", "Kabelzug-Flys (Crossover)", "Crucifixo no cabo (crossover)"),
    "cable-lateral-raise": ("Élévations latérales à la poulie", "Elevaciones laterales en polea", "Seitheben am Kabel", "Elevação lateral no cabo"),
    "cable-front-raise": ("Élévations frontales à la poulie", "Elevaciones frontales en polea", "Frontheben am Kabel", "Elevação frontal no cabo"),
    "cable-curl": ("Curl à la poulie", "Curl en polea", "Kabel-Curl", "Rosca no cabo"),
    "cable-rope-hammer-curl": ("Curl marteau à la corde", "Curl martillo con cuerda en polea", "Hammer-Curl am Seil", "Rosca martelo com corda no cabo"),
    "tricep-pushdown": ("Extension triceps à la poulie", "Extensión de tríceps en polea", "Trizepsdrücken am Kabel", "Tríceps na polia"),
    "rope-tricep-pushdown": ("Extension triceps à la corde", "Extensión de tríceps con cuerda", "Trizepsdrücken mit Seil", "Tríceps com corda"),
    "cable-overhead-extension": ("Extension triceps poulie au-dessus de la tête", "Extensión de tríceps en polea sobre la cabeza", "Trizepsdrücken über Kopf am Kabel", "Extensão de tríceps no cabo acima da cabeça"),
    "cable-tricep-kickback": ("Kickback triceps à la poulie", "Patada de tríceps en polea", "Trizeps-Kickback am Kabel", "Tríceps coice no cabo"),
    "cable-glute-kickback": ("Kickback fessier à la poulie", "Patada de glúteo en polea", "Glute Kickback am Kabel", "Coice de glúteo no cabo"),
    "cable-pull-through": ("Pull through à la poulie", "Pull through en polea", "Pull Through am Kabel", "Pull through no cabo"),
    "cable-crunch": ("Crunch à la poulie", "Crunch en polea", "Crunch am Kabel", "Abdominal na polia"),
    "cable-woodchop": ("Rotation bûcheron à la poulie", "Leñador en polea", "Holzfäller am Kabel", "Lenhador no cabo"),
    "cable-shrug": ("Haussement d'épaules à la poulie", "Encogimiento en polea", "Schulterheben am Kabel", "Encolhimento no cabo"),
    "cable-upright-row": ("Rowing menton à la poulie", "Remo al mentón en polea", "Aufrechtes Rudern am Kabel", "Remada alta no cabo"),
    # ---- Bodyweight (v1) ---------------------------------------------------
    "pull-ups": ("Tractions", "Dominadas", "Klimmzüge", "Barra fixa (pull-up)"),
    "chin-ups": ("Tractions supination", "Dominadas supinas", "Klimmzüge im Untergriff", "Barra supinada (chin-up)"),
    "muscle-ups": ("Muscle-ups", "Muscle-ups", "Muscle-ups", "Muscle-ups"),
    "inverted-row": ("Rowing inversé (australien)", "Remo invertido", "Umgekehrtes Rudern", "Remada invertida"),
    "push-ups": ("Pompes", "Flexiones", "Liegestütze", "Flexões"),
    "diamond-push-up": ("Pompes diamant", "Flexiones diamante", "Diamant-Liegestütze", "Flexões diamante"),
    "wide-push-up": ("Pompes prise large", "Flexiones abiertas", "Liegestütze weit", "Flexões abertas"),
    "decline-push-up": ("Pompes déclinées", "Flexiones declinadas", "Negativ-Liegestütze", "Flexões declinadas"),
    "pike-push-up": ("Pompes piquées", "Flexiones pike", "Pike-Liegestütze", "Flexões pike"),
    "handstand-push-up": ("Pompes en équilibre", "Flexiones en pino", "Handstand-Liegestütze", "Flexões em parada de mão"),
    "dips": ("Dips", "Fondos", "Dips", "Mergulhos (dips)"),
    "bodyweight-squat": ("Squat au poids du corps", "Sentadilla con peso corporal", "Kniebeuge mit Körpergewicht", "Agachamento livre"),
    "bodyweight-lunge": ("Fente au poids du corps", "Zancada con peso corporal", "Ausfallschritt mit Körpergewicht", "Afundo livre"),
    "pistol-squat": ("Pistol squat", "Sentadilla pistol", "Pistol Squat", "Agachamento pistol"),
    "jump-squat": ("Squat sauté", "Sentadilla con salto", "Sprungkniebeuge", "Agachamento com salto"),
    "bodyweight-step-up": ("Montée sur banc au poids du corps", "Subida al cajón con peso corporal", "Step-up mit Körpergewicht", "Subida no caixote livre"),
    "glute-bridge": ("Pont fessier", "Puente de glúteos", "Glute Bridge (Beckenheben)", "Ponte de glúteo"),
    "nordic-curl": ("Leg curl nordique", "Curl nórdico de isquios", "Nordic Hamstring Curl", "Curl nórdico"),
    "calf-raise-bodyweight": ("Extension des mollets au poids du corps", "Elevación de gemelos con peso corporal", "Wadenheben mit Körpergewicht", "Elevação de panturrilha livre"),
    "hanging-leg-raise": ("Relevé de jambes suspendu", "Elevación de piernas colgado", "Hängendes Beinheben", "Elevação de pernas suspenso"),
    "hanging-knee-raise": ("Relevé de genoux suspendu", "Elevación de rodillas colgado", "Hängendes Knieheben", "Elevação de joelhos suspenso"),
    "toes-to-bar": ("Toes to bar (pieds à la barre)", "Toes to bar (pies a la barra)", "Toes to Bar", "Toes to bar (pés à barra)"),
    "sit-ups": ("Redressements assis", "Abdominales (sit-ups)", "Sit-ups", "Abdominais (sit-up)"),
    "crunches": ("Crunchs", "Encogimientos (crunches)", "Crunches", "Abdominais crunch"),
    "bicycle-crunch": ("Crunch bicyclette", "Crunch bicicleta", "Fahrrad-Crunch", "Abdominal bicicleta"),
    "russian-twist": ("Russian twist", "Giro ruso", "Russian Twist", "Giro russo"),
    "flutter-kicks": ("Battements de jambes", "Patadas de tijera", "Flutter Kicks (Scherenschlag)", "Tesoura (flutter kicks)"),
    "mountain-climbers": ("Mountain climbers", "Escaladores", "Mountain Climbers", "Escalador"),
    "burpees": ("Burpees", "Burpees", "Burpees", "Burpees"),
    "superman": ("Superman", "Superman", "Superman", "Superman"),
    "hyperextension": ("Hyperextension lombaire", "Hiperextensión lumbar", "Hyperextension (Rücken)", "Hiperextensão lombar"),
    "plank": ("Planche", "Plancha", "Unterarmstütz (Plank)", "Prancha"),
    "side-plank": ("Planche latérale", "Plancha lateral", "Seitlicher Unterarmstütz", "Prancha lateral"),
    "wall-sit": ("Chaise contre le mur", "Sentadilla isométrica en pared", "Wandsitz", "Cadeira na parede"),
    "l-sit": ("L-sit", "L-sit", "L-Sit", "L-sit"),
    # ---- Barbell variants (v2) --------------------------------------------
    "wide-grip-bench": ("Développé couché prise large", "Press de banca con agarre ancho", "Bankdrücken weiter Griff", "Supino com pegada aberta"),
    "paused-bench": ("Développé couché avec pause", "Press de banca con pausa", "Bankdrücken mit Pause", "Supino com pausa"),
    "high-bar-squat": ("Squat barre haute", "Sentadilla con barra alta", "Kniebeuge mit hoher Hantelablage", "Agachamento com barra alta"),
    "low-bar-squat": ("Squat barre basse", "Sentadilla con barra baja", "Kniebeuge mit tiefer Hantelablage", "Agachamento com barra baixa"),
    "pause-squat": ("Squat avec pause", "Sentadilla con pausa", "Kniebeuge mit Pause", "Agachamento com pausa"),
    "tempo-squat": ("Squat tempo", "Sentadilla a tempo", "Tempo-Kniebeuge", "Agachamento em tempo"),
    "safety-bar-squat": ("Squat à la barre safety", "Sentadilla con barra de seguridad", "Safety-Bar-Kniebeuge", "Agachamento com safety bar"),
    "underhand-barbell-row": ("Rowing barre en supination", "Remo con barra supino", "Langhantelrudern im Untergriff", "Remada com barra supinada"),
    "seal-row": ("Seal row (rowing allongé)", "Remo seal (tumbado)", "Seal Row", "Remada seal (deitado)"),
    "clean-pull": ("Tirage d'épaulé", "Tirón de cargada", "Clean Pull (Umsetzzug)", "Puxada de clean"),
    "hang-clean": ("Épaulé depuis suspension", "Cargada colgante", "Hang Clean", "Hang clean"),
    "hang-snatch": ("Arraché depuis suspension", "Arrancada colgante", "Hang Snatch", "Hang snatch"),
    "trap-bar-shrug": ("Haussement d'épaules à la trap bar", "Encogimiento con barra trap", "Schulterheben mit Trap Bar", "Encolhimento com trap bar"),
    "ez-bar-skull-crusher": ("Barre au front à la barre EZ", "Press francés con barra Z", "Stirndrücken mit SZ-Stange", "Tríceps testa com barra W"),
    "landmine-rotation": ("Rotation landmine", "Rotación landmine", "Landmine-Rotation", "Rotação landmine"),
    "barbell-reverse-wrist-curl": ("Curl inversé des poignets à la barre", "Curl de muñeca invertido con barra", "Reverse Handgelenk-Curl mit Langhantel", "Rosca de punho inversa com barra"),
    "behind-back-wrist-curl": ("Curl des poignets derrière le dos", "Curl de muñeca tras la espalda", "Handgelenk-Curl hinter dem Rücken", "Rosca de punho atrás das costas"),
    "barbell-glute-bridge": ("Pont fessier à la barre", "Puente de glúteos con barra", "Glute Bridge mit Langhantel", "Ponte de glúteo com barra"),
    "incline-db-fly": ("Écarté incliné aux haltères", "Aperturas inclinadas con mancuernas", "Schrägbank-Flys mit Kurzhanteln", "Crucifixo inclinado com halteres"),
    "seated-db-press": ("Développé épaules assis aux haltères", "Press de hombros sentado con mancuernas", "Schulterdrücken sitzend mit Kurzhanteln", "Desenvolvimento sentado com halteres"),
    "single-arm-db-press": ("Développé à un bras aux haltères", "Press a una mano con mancuerna", "Einarmiges Kurzhanteldrücken", "Desenvolvimento unilateral com halter"),
    "alternating-db-curl": ("Curl alterné aux haltères", "Curl alterno con mancuernas", "Wechselnder Kurzhantel-Curl", "Rosca alternada com halteres"),
    "cross-body-hammer-curl": ("Curl marteau croisé", "Curl martillo cruzado", "Cross-Body Hammer-Curl", "Rosca martelo cruzada"),
    "single-arm-db-overhead-extension": ("Extension triceps à un bras au-dessus de la tête", "Extensión de tríceps a una mano sobre la cabeza", "Einarmiges Trizepsdrücken über Kopf", "Extensão de tríceps unilateral acima da cabeça"),
    "dumbbell-squat": ("Squat aux haltères", "Sentadilla con mancuernas", "Kniebeuge mit Kurzhanteln", "Agachamento com halteres"),
    "db-hip-thrust": ("Hip thrust aux haltères", "Empuje de cadera con mancuerna", "Hip Thrust mit Kurzhantel", "Elevação de quadril com halter"),
    "single-leg-rdl": ("Soulevé de terre roumain unijambe", "Peso muerto rumano a una pierna", "Einbeiniges rumänisches Kreuzheben", "Levantamento terra romeno unilateral"),
    "plate-front-raise": ("Élévation frontale au disque", "Elevación frontal con disco", "Frontheben mit Gewichtsscheibe", "Elevação frontal com anilha"),
    "kettlebell-push-press": ("Push press kettlebell", "Push press con pesa rusa", "Push Press mit Kettlebell", "Push press com kettlebell"),
    "kettlebell-high-pull": ("Tirage haut kettlebell", "Tirón alto con pesa rusa", "High Pull mit Kettlebell", "Puxada alta com kettlebell"),
    "kettlebell-windmill": ("Moulin à vent kettlebell", "Molino con pesa rusa", "Kettlebell Windmill", "Moinho com kettlebell"),
    "incline-machine-press": ("Développé incliné à la machine", "Press inclinado en máquina", "Schrägdrücken (Maschine)", "Supino inclinado na máquina"),
    "decline-machine-press": ("Développé décliné à la machine", "Press declinado en máquina", "Negativdrücken (Maschine)", "Supino declinado na máquina"),
    "chest-supported-row": ("Rowing avec appui pectoral", "Remo con apoyo en el pecho", "Rudern mit Brustauflage", "Remada com apoio no peito"),
    "hammer-strength-row": ("Rowing Hammer Strength", "Remo Hammer Strength", "Hammer-Strength-Rudern", "Remada Hammer Strength"),
    "pendulum-squat": ("Pendulum squat", "Sentadilla péndulo", "Pendel-Kniebeuge", "Agachamento pêndulo"),
    "belt-squat": ("Squat à la ceinture", "Sentadilla con cinturón", "Gürtel-Kniebeuge", "Agachamento com cinto"),
    "single-leg-press": ("Presse à cuisses unijambe", "Prensa de pierna a una pierna", "Einbeinige Beinpresse", "Leg press unilateral"),
    "standing-leg-curl": ("Leg curl debout", "Curl femoral de pie", "Beinbeuger stehend", "Flexora em pé"),
    "smith-incline-press": ("Développé incliné à la Smith", "Press inclinado en máquina Smith", "Schrägdrücken an der Multipresse", "Supino inclinado no Smith"),
    "smith-front-squat": ("Squat avant à la Smith", "Sentadilla frontal en máquina Smith", "Frontkniebeuge an der Multipresse", "Agachamento frontal no Smith"),
    "smith-hip-thrust": ("Hip thrust à la Smith", "Empuje de cadera en máquina Smith", "Hip Thrust an der Multipresse", "Elevação de quadril no Smith"),
    "smith-shrug": ("Haussement d'épaules à la Smith", "Encogimiento en máquina Smith", "Schulterheben an der Multipresse", "Encolhimento no Smith"),
    "donkey-calf-raise": ("Extension des mollets donkey", "Elevación de gemelos donkey", "Donkey Wadenheben", "Panturrilha donkey (burrinho)"),
    "leg-press-calf-raise": ("Mollets à la presse", "Gemelos en prensa", "Wadenheben an der Beinpresse", "Panturrilha no leg press"),
    "smith-calf-raise": ("Mollets à la Smith", "Gemelos en máquina Smith", "Wadenheben an der Multipresse", "Panturrilha no Smith"),
    "cable-chest-press": ("Développé pectoraux à la poulie", "Press de pecho en polea", "Brustdrücken am Kabel", "Supino no cabo"),
    "wide-grip-pulldown": ("Tirage vertical prise large", "Jalón con agarre ancho", "Latzug weiter Griff", "Puxada com pegada aberta"),
    "reverse-grip-pulldown": ("Tirage vertical en supination", "Jalón con agarre supino", "Latzug im Untergriff", "Puxada com pegada supinada"),
    "single-arm-pulldown": ("Tirage vertical à un bras", "Jalón a una mano", "Einarmiger Latzug", "Puxada unilateral"),
    "straight-bar-pushdown": ("Extension triceps à la barre droite", "Extensión de tríceps con barra recta", "Trizepsdrücken mit gerader Stange", "Tríceps na polia com barra reta"),
    "v-bar-pushdown": ("Extension triceps à la barre en V", "Extensión de tríceps con barra en V", "Trizepsdrücken mit V-Stange", "Tríceps na polia com barra em V"),
    "reverse-grip-pushdown": ("Extension triceps en supination", "Extensión de tríceps con agarre supino", "Trizepsdrücken im Untergriff", "Tríceps na polia com pegada supinada"),
    "high-cable-curl": ("Curl à la poulie haute", "Curl en polea alta", "Curl am hohen Kabel", "Rosca na polia alta"),
    "leaning-cable-lateral-raise": ("Élévation latérale penchée à la poulie", "Elevación lateral inclinada en polea", "Seitheben am Kabel (gelehnt)", "Elevação lateral inclinada no cabo"),
    "cable-external-rotation": ("Rotation externe à la poulie", "Rotación externa en polea", "Außenrotation am Kabel", "Rotação externa no cabo"),
    "cable-internal-rotation": ("Rotation interne à la poulie", "Rotación interna en polea", "Innenrotation am Kabel", "Rotação interna no cabo"),
    "cable-hip-abduction": ("Abduction de hanche à la poulie", "Abducción de cadera en polea", "Hüftabduktion am Kabel", "Abdução de quadril no cabo"),
    "cable-hip-adduction": ("Adduction de hanche à la poulie", "Aducción de cadera en polea", "Hüftadduktion am Kabel", "Adução de quadril no cabo"),
    "pallof-press": ("Pallof press", "Press Pallof", "Pallof Press", "Pallof press"),
    "cable-wrist-curl": ("Curl des poignets à la poulie", "Curl de muñeca en polea", "Handgelenk-Curl am Kabel", "Rosca de punho no cabo"),
    # ---- Bodyweight (v3) ---------------------------------------------------
    "incline-push-up": ("Pompes inclinées", "Flexiones inclinadas", "Liegestütze erhöht (incline)", "Flexões inclinadas"),
    "deficit-push-up": ("Pompes en déficit", "Flexiones con déficit", "Liegestütze mit Defizit", "Flexões com déficit"),
    "assisted-dip": ("Dips assistés", "Fondos asistidos", "Assistierte Dips", "Mergulhos assistidos"),
    "neutral-grip-pull-up": ("Tractions prise neutre", "Dominadas con agarre neutro", "Klimmzüge im Neutralgriff", "Barra com pegada neutra"),
    "wide-grip-pull-up": ("Tractions prise large", "Dominadas con agarre ancho", "Klimmzüge im Weitgriff", "Barra com pegada aberta"),
    "assisted-pull-up": ("Tractions assistées", "Dominadas asistidas", "Assistierte Klimmzüge", "Barra assistida"),
    "trx-row": ("Rowing TRX", "Remo TRX", "TRX-Rudern", "Remada TRX"),
    "trx-push-up": ("Pompes TRX", "Flexiones TRX", "TRX-Liegestütze", "Flexões TRX"),
    "trx-biceps-curl": ("Curl biceps TRX", "Curl de bíceps TRX", "TRX-Bizeps-Curl", "Rosca de bíceps TRX"),
    "trx-triceps-extension": ("Extension triceps TRX", "Extensión de tríceps TRX", "TRX-Trizepsstrecken", "Extensão de tríceps TRX"),
    "bench-dip": ("Dips sur banc", "Fondos en banco", "Bank-Dips", "Mergulho no banco"),
    "back-extension-45": ("Extension lombaire à 45°", "Extensión lumbar a 45°", "Rückenstrecken 45°", "Extensão lombar a 45°"),
    "reverse-hyperextension": ("Hyperextension inversée", "Hiperextensión inversa", "Reverse Hyperextension", "Hiperextensão inversa"),
    "bird-dog": ("Bird dog (chien d'arrêt)", "Bird dog (perro de muestra)", "Bird Dog", "Bird dog"),
    "dead-bug": ("Dead bug", "Bicho muerto (dead bug)", "Dead Bug", "Dead bug (inseto morto)"),
    "reverse-lunge": ("Fente arrière", "Zancada inversa", "Ausfallschritt rückwärts", "Afundo reverso"),
    "lateral-lunge": ("Fente latérale", "Zancada lateral", "Seitlicher Ausfallschritt", "Afundo lateral"),
    "curtsy-lunge": ("Fente croisée (curtsy)", "Zancada cruzada (curtsy)", "Curtsy-Ausfallschritt", "Afundo cruzado (curtsy)"),
    "sissy-squat": ("Sissy squat", "Sentadilla sissy", "Sissy Squat", "Agachamento sissy"),
    "assisted-pistol-squat": ("Pistol squat assisté", "Sentadilla pistol asistida", "Assistierter Pistol Squat", "Agachamento pistol assistido"),
    "glute-ham-raise": ("Glute-ham raise", "Elevación glúteo-femoral", "Glute-Ham Raise", "Glute-ham raise"),
    "stability-ball-leg-curl": ("Leg curl sur swiss ball", "Curl femoral con fitball", "Beinbeuger am Gymnastikball", "Flexora na bola suíça"),
    "single-leg-hip-thrust": ("Hip thrust unijambe", "Empuje de cadera a una pierna", "Einbeiniger Hip Thrust", "Elevação de quadril unilateral"),
    "single-leg-glute-bridge": ("Pont fessier unijambe", "Puente de glúteos a una pierna", "Einbeinige Glute Bridge", "Ponte de glúteo unilateral"),
    "frog-pump": ("Frog pump (pont grenouille)", "Frog pump (puente rana)", "Frog Pump", "Frog pump (ponte sapo)"),
    "donkey-kick": ("Donkey kick (ruade)", "Patada de burro", "Donkey Kick", "Coice de burro"),
    "fire-hydrant": ("Fire hydrant (abduction quadrupédie)", "Hidrante (fire hydrant)", "Fire Hydrant", "Fire hydrant (hidrante)"),
    "clamshell": ("Clamshell (coquille)", "Almeja (clamshell)", "Clamshell (Muschel)", "Concha (clamshell)"),
    "single-leg-calf-raise": ("Extension des mollets unijambe", "Elevación de gemelos a una pierna", "Einbeiniges Wadenheben", "Panturrilha unilateral"),
    "tibialis-raise": ("Tibialis raise (relevé tibial)", "Elevación de tibial", "Tibialis-Heben", "Elevação de tibial"),
    "reverse-crunch": ("Crunch inversé", "Crunch invertido", "Reverse Crunch", "Abdominal invertido"),
    "decline-crunch": ("Crunch décliné", "Crunch declinado", "Negativ-Crunch", "Abdominal declinado"),
    "decline-sit-up": ("Redressements assis déclinés", "Abdominales declinados", "Negativ-Sit-ups", "Abdominais declinados"),
    "v-up": ("V-ups (relevés en V)", "V-ups (abdominales en V)", "V-Ups", "Abdominal em V (V-up)"),
    "lying-leg-raise": ("Relevé de jambes au sol", "Elevación de piernas tumbado", "Beinheben liegend", "Elevação de pernas deitado"),
    "ab-wheel-rollout": ("Roulette abdominale (ab wheel)", "Rueda abdominal", "Bauchrad (Ab Wheel)", "Roda abdominal"),
    "dead-hang": ("Suspension passive (dead hang)", "Colgarse en barra (dead hang)", "Passives Hängen (Dead Hang)", "Pendurado na barra (dead hang)"),
    "hollow-hold": ("Hollow hold (maintien creux)", "Hollow hold (posición hueca)", "Hollow Hold", "Hollow hold (posição oca)"),
}

with open(CATALOG, encoding="utf-8") as f:
    catalog = json.load(f)

ids = [e["id"] for e in catalog["exercises"]]
names_en = {e["id"]: e["name"] for e in catalog["exercises"]}

missing = [i for i in ids if i not in T]
extra = [i for i in T if i not in names_en]
if missing:
    sys.exit("Missing translations for: " + ", ".join(missing))
if extra:
    sys.exit("Translations for unknown ids: " + ", ".join(extra))

def dart_str(value):
    """Emit a Dart string literal, preferring single quotes to satisfy the
    `prefer_single_quotes` lint (use double quotes only when the value itself
    contains a single quote but no double quote)."""
    v = value.replace("\\", "\\\\").replace("$", "\\$")
    if "'" in v and '"' not in v:
        return '"%s"' % v
    return "'%s'" % v.replace("'", "\\'")


lines = []
lines.append("// GENERATED FILE — do not edit by hand.")
lines.append("// Run `python tool/generate_exercise_names.py` to regenerate.")
lines.append("//")
lines.append("// Localized display names for every catalog exercise, keyed by id then")
lines.append("// language code. English is the catalog's canonical name; the other")
lines.append("// languages are translations used for display and cross-language search.")
lines.append("")
lines.append("const Map<String, Map<String, String>> kExerciseNames = {")
for i in ids:
    fr, es, de, pt = T[i]
    row = {
        "en": names_en[i],
        "fr": fr,
        "es": es,
        "de": de,
        "pt": pt,
    }
    parts = ", ".join(
        "%s: %s" % (dart_str(k), dart_str(v)) for k, v in row.items()
    )
    lines.append("  %s: {%s}," % (dart_str(i), parts))
lines.append("};")
lines.append("")

with open(OUT, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))

print("Wrote %d exercises to %s" % (len(ids), OUT))
