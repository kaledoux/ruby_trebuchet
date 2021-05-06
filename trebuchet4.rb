require 'io/console'

# Module for text and screen clearing methods
module UtilityFunctions
  def prompt(text)
    puts "\n=|=|=> #{text}"
  end

  def clear_screen_timed(seconds)
    sleep(seconds)
    system('clear')
  end

  def clear_screen_with_input
    prompt('Press anything to continue. No, not that... Press any KEY:')
    STDIN.getch
    system('clear')
  end
end

# Beams used for building trebuchet frame and lever arm
class WoodenBeam
  attr_reader :length

  def initialize(length)
    @length = length
  end

  def self.gather_beams(quantity, length)
    beam_collection = []
    quantity.times { beam_collection << WoodenBeam.new(length) }
    beam_collection
  end

  def status
    puts "#{self}: check!"
  end

  def to_s
    "A sturdy, wooden beam #{length} meters long"
  end
end

# Collection of WoodenBeams
class PileOfBeams < WoodenBeam
  attr_reader :beams, :quantity

  def initialize(how_many, length)
    @beams = gather_beams(how_many, length)
    @quantity = how_many
  end

  def gather_beams(quantity, length)
    beam_collection = []
    quantity.times { beam_collection << WoodenBeam.new(length) }
    beam_collection
  end

  def status
    puts "#{beams.first}: yeeeep x(#{quantity})!"
  end
end

# Old car used for counterweight and sourcing axles
class RustyOldCar
  attr_accessor :make, :model, :weight, :axles

  def initialize(make, model, weight)
    @make = make
    @model = model
    @weight = weight
    @axles = 2
  end

  def remove_axle
    raise StandardError, 'No remaining axles!' if axles < 1

    self.axles -= 1
    self.weight -= 200
    RustyCarAxle.new
  end

  def status
    puts "#{self}: got it!"
  end

  def to_s
    "Rusty #{make} #{model} "
  end
end

# Axles taken from instances of RustyOldCar
class RustyCarAxle
  def status
    puts 'Rusty axle torn from a hoopty: done!'
  end
end

# Chair used as sling
class MustyArmChair
  def status
    puts "'Well-loved', lumpy armchair: yes!"
  end
end

# Rope is used to attach other objects together, track length
class SaltyBoatRope
  attr_accessor :length

  def initialize(length)
    @length = length
  end

  def attach(how_much)
    if length > how_much
      self.length -= how_much
    else
      puts 'Not enough rope left for that!'
    end
  end

  def status
    puts "#{self}: yup!"
  end

  def to_s
    "#{length} meters of fraying rope that smells vaguely like Margate, Kent..."
  end
end

# Ants can be collected and form the main means of raising the counterweight
class CarpenterAntColony
  ANT_MOODS = %w[hungry bitter grumbling malcontent raucous].freeze

  attr_reader :colony_size

  def initialize(how_many_ants)
    @colony_size = how_many_ants
  end

  def to_s
    "#{colony_size} #{ANT_MOODS.sample}, marching ants"
  end

  def status
    puts "#{self} secured by floss: check x(#{colony_size})!"
  end
end

# Device built to perform complete cycle for launching passengers
class Trebuchet
  include UtilityFunctions

  def initialize(how_many_ants)
    @materials = { support_beams: PileOfBeams.new(6, 15),
                   lever_beam: WoodenBeam.new(25),
                   rope: SaltyBoatRope.new(120),
                   counterweight: RustyOldCar.new(:Vauxhall, :Corsa, 997),
                   axle: RustyOldCar.new(:Ford, :Fiesta, 600).remove_axle,
                   sling: MustyArmChair.new,
                   pull_force: CarpenterAntColony.new(how_many_ants) }

    @support_beams = nil
    @lever_beam = nil
    @rope = materials[:rope]
    @counterweight = nil
    @counterweight_secured = false
    @axle = nil
    @sling = nil
    @pull_force = nil
    @passenger = nil
    @assembled = false
    @armed = false
  end

  def complete_cycle
    clear_screen_timed(0)
    display_greeting
    parts_checklist_cycle
    assemble
    arm
    fire
  end

  private

  COUNTERWEIGHT_MAX_HEIGHT = 12
  BEAMS_NEEDED = 6

  attr_accessor :support_beams, :lever_beam, :rope, :counterweight, \
                :axle, :sling, :pull_force, :passenger, :assembled, :armed, \
                :counterweight_secured, :ants_mounted, :materials

  def check_status
    materials.each_value(&:status)
  end

  def parts_checklist_cycle
    puts "Before we assemble anything, let's make sure everything is in order:"
    check_status
    puts "\nWell, gosh, that seems to be everything!"
    clear_screen_with_input
  end

  def assemble
    display_start_assembly
    build_frame
    attach_axle
    attach_lever_beam_to_axle
    attach_sling
    secure_counterweight
    mount_ants_to_lever_beam
    @assembled = true
    display_finish_assembly
  end

  def arm
    @passenger = get_passenger
    display_greeting_passenger
    display_raised_height
    @armed = true
    display_ready_to_fire
    clear_screen_with_input
  end

  def fire
    display_goodbye_to_passenger
    if confirm_fire?(get_final_words)
      clear_screen_timed(0)
      change_passenger_and_armed_status
      display_trebuchet_art
      display_goodbye
    else
      puts 'LAUNCH ABORTED- ...maybe next time'
    end
  end

  def display_greeting
    puts 'Time to build the next great advancement in the modern commute!'
    clear_screen_with_input
  end

  def display_start_assembly
    puts "We have the supplies in order! \n" \
         "Let's start assembling the trebuchet!... what will the neighbors say?"
  end

  def build_frame
    if materials[:support_beams].beams.size < BEAMS_NEEDED
      raise StandardError, 'Not Enough Beams!'
    end

    materials[:support_beams].beams.each { rope.attach(15) }
    self.support_beams = materials[:support_beams]
    puts "\nFrame has been built!"
  end

  def attach_axle
    raise StandardError, 'Build the frame first...' unless support_beams

    self.axle = materials[:axle]
    puts 'Axle attached!'
  end

  def attach_lever_beam_to_axle
    raise StandardError, 'You need to attach the axle!' unless axle

    unless materials[:lever_beam].length > 20
      raise StandardError, 'You need a longer lever beam!'
    end

    self.lever_beam = materials[:lever_beam]
    puts 'Lever beam has been attached!'
  end

  def attach_sling
    raise StandardError, "The lever isn't ready yet!" unless lever_beam

    if materials[:sling]
      puts 'Sling attached! Also, I found some loose change in the cushions!'
    end

    self.sling = materials[:sling]
  end

  def secure_counterweight
    raise StandardError, 'Attach the sling first!' unless sling

    puts 'Counterweight is on the lever!'
    self.counterweight = materials[:counterweight]
  end

  def mount_ants_to_lever_beam
    raise StandardError, "The weight isn't ready yet!" unless counterweight

    puts 'Ants are mounted to the lever beam. Not happy, but mounted.'
    self.pull_force = materials[:pull_force]
  end

  def display_finish_assembly
    puts "\nWell, that does it! The trebuchet is assembled." \
         "\nOnly one thing to do now..."
    clear_screen_with_input
  end

  def get_passenger
    new_passenger = ''
    prompt("Who's getting in this thing?")
    loop do
      new_passenger = gets.chomp
      break unless /[^A-Za-z]/.match(new_passenger) || new_passenger.empty?

      prompt("Yeah, that's well and good, but I need a name...(letters only!)")
    end
    new_passenger.capitalize
  end

  def display_greeting_passenger
    puts "Howdy, #{passenger}! Let's get this show on the road..."
    clear_screen_with_input
  end

  def display_raised_height
    puts "#{pull_force} raise the #{counterweight}#{COUNTERWEIGHT_MAX_HEIGHT}"\
         ' meters off the ground!'
  end

  def display_ready_to_fire
    if armed
      puts "The trebuchet is ready to fire! \n" \
           "Say your praye- Ahem, I mean... \n" \
           'Have fun!'
    else
      puts "This is akward... You aren't quite ready to fire yet."
    end
  end

  def display_goodbye_to_passenger
    puts 'Commence the seige!'
    puts "...it's not a seige? It's a commute?"
    puts 'Whatever, just fire the thing!'
    puts "Safe travels, #{passenger}!"
    puts '(Remember to tuck and roll when you reach your destination)'
  end

  def get_final_words
    prompt("#{passenger}, are you ready to soar like an eagle?" \
         " Press 'f' to fire or anything else to abort:")
    STDIN.getch
  end

  def confirm_fire?(final_words)
    final_words.downcase == 'f'
  end

  def change_passenger_and_armed_status
    self.passenger = nil
    self.armed = false
  end

  def display_trebuchet_art
    puts <<-TREB
                                 .`.
                                / `.`.
         ______________________/____`_`____________________________
        / .''.  _ !  F   _     I     _     R    _     E  !  __..--->.
        \\ '()'       _       .''.        _       ____...---'       .'
         |_||______.`.__  .' .'______......-----'                 /
          .||-||-./ `.`.' .'   \\/_/  `./   /`.`.                .'
        .'_||__.'/ (O)`.`.    \\/_/     `./   /`.`.             /
        /_ -  _\\/\\     /`.`. \\/_/        `./   /`.`.          /
        |>-::-</\\   ./   /`.`. /___________`./   /`.`._     .'
        '-----/\\  \\/ `./   /`.`._____________`._____` .|   /
             /\\  \\/_/  `./   /`.`.________________.'.'.' .'
            /\\  \\/_/   .-`./   /`.`.---------/``\\-----.-'
           /\\  \\/_/  .'~ _ `./   /`.`. _ ~   (==)`._.'
        .'/\\  \\/_/  '--------`./   /`.`.-----|__|--'
      .' /\\  \\/ /______________`./   /`.`..'.'.'
    .'__/____/___________________`._____` .'.'
    |____________________________________|.'
    TREB
  end

  def display_goodbye
    puts "There they go, slipped loose the surly bonds and all that. \n" \
         "Another successful commute completed!\n" \
         "...and a somewhat thematic avoidance of studying to boot!\n" \
         "Until you next time, or not. We'll see."
  end
end

treb = Trebuchet.new(175_000)
treb.complete_cycle
