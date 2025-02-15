require 'gosu'

class Player
  attr_reader :player_x, :player_y, :vel_car, :collision_x, :collision_y

  def initialize(velocidade)
    @player_car_image = Gosu::Image.new("images/car1.png")
    @player_x = 280
    @player_y = 315
    @vel_car = velocidade
    @width = 80
    @height = 200
    @collision_x = nil
    @collision_y = nil
  end

  # Metodo responsável de mover o F1.
  def move_player(janela_x, janela_y)
    if Gosu.button_down?(Gosu::KB_LEFT)
      @player_x -= @vel_car if @player_x > 0
    end
    if Gosu.button_down?(Gosu::KB_RIGHT)
      @player_x += @vel_car if @player_x < janela_x - @width
    end
    if Gosu.button_down?(Gosu::KB_UP)
      @player_y -= @vel_car if @player_y > 0
    end
    if Gosu.button_down?(Gosu::KB_DOWN)
      @player_y += @vel_car if @player_y < janela_y - @height
    end
  end

  # Método para desenhar o jogador na tela
  def draw_car
    @player_car_image.draw(@player_x, @player_y, 2)
  end
  
  # Método para verificar colisão com outro retângulo (como oponente)
  def colidiu?(obstaculo)
    # Verificar se há colisão
    if (@player_x < obstaculo.x + obstaculo.width && 
        @player_x + @width > obstaculo.x &&
        @player_y < obstaculo.y + obstaculo.height &&
        @player_y + @height > obstaculo.y)
      
      # Calcula os pontos de colisão
      @collision_x = (@player_x + obstaculo.x) / 2
      if (obstaculo.y + obstaculo.height) >= (@player_y + @height)
        @collision_y = obstaculo.y - (obstaculo.height / 2)
      else
        @collision_y = obstaculo.y + (obstaculo.height / 2)
      end
      return true
    else
      # Retorna false se não houver colisão
      return false
    end
  end
end



class Obstaculos
  attr_reader :x, :y, :width, :height, :obstacles_image

  def initialize(janela_x, car_position_x)
    @width = 80 #largura do F1 inimigo: 80px
    @height = 200 #altura do F1 inimigo: 200px
    @x = car_position_x if car_position_x < (janela_x - @width)
    @y = - (@height)
    @image_car = ["images/car2.png", "images/car3.png", "images/car4.png", "images/car5.png", "images/car6.png", "images/car7.png", "images/car8.png"]
    @obstacles_image = Gosu::Image.new(@image_car[rand(7)])
  end

  def draw_obs
    @obstacles_image.draw(@x, @y, 1)
  end

  def atualiza_cone(vel_car_obs, janela_y)
    # movimenta o cone
    @y += vel_car_obs
  end
end



class CarRaceGame < Gosu::Window
  attr_reader :vel_car_obs, :janela_x, :janela_y

  def initialize
    @janela_x = 640
    @janela_y = 540
    @vel_car_obs = 4

    super @janela_x, @janela_y, false
    self.caption = "Game F1 2D em Ruby"

    @car = nil
    @menu = true
    @obstacles = []
    @obstacle_timer = 0
    @game_over = false
    @points = 0
    @background_image = Gosu::Image.new("images/asfalto.png")
    @crash_image = Gosu::Image.new("images/explosion2.png")
  end

  # Sempre vai executar primeiro o UPDATE
  def update
    if @game_over
      return
    else 
      inicio_jogo(@menu)

      @car.move_player(@janela_x, @janela_y)

      update_obstacles

      # Verifica colisão entre o jogador e cada oponente
      @obstacles.each do |oponente|
        if @car.colidiu?(oponente)
          @game_over = true
        end
      end
    end
  end
  
  def draw
    @background_image.draw(0, 0, 0)
    
    @car.draw_car
    
    @obstacles.each { |cone| cone.draw_obs}
    
    # Desenho do texto ou pontuação (se necessário)

    if @game_over
      @crash_image.draw(@car.collision_x, @car.collision_y, 3)
      exibir_game_over 
    end
  end

  def update_obstacles
    # incrementa o obstacle_timer a cada 1 milésimo de segundos
    # NÃO MEXER NOS PARÂMETROS (intervalo dos carros)
    @obstacle_timer += (@vel_car_obs)
    if @obstacle_timer > (420)
      @obstacles << Obstaculos.new(@janela_x, @car.player_x)
      @obstacle_timer = 0
    end    

    # Atualiza a posição dos obstáculos
    @obstacles.each{|cone| cone.atualiza_cone(@vel_car_obs, @anela_y)}

    @obstacles.each do |cone|
      if cone.y > @janela_y
        @points += 1
      end
    end
    
    @obstacles.reject! { |cone| cone.y > @janela_y }
  end

  def inicio_jogo(menu)
    if (menu)
      @car = Player.new(@vel_car_obs)
      @obstacles << Obstaculos.new(@janela_x, @car.player_x)
      @menu = false
    end
  end

  def exibir_game_over
    font = Gosu::Font.new(self, Gosu.default_font_name, 48)
    font.draw_text("GAME OVER!", 180, 200, 10, 1, 1, Gosu::Color::RED)
    font.draw_text("Você fez #{@points} pontos!", 170, 300, 10, 1, 1, Gosu::Color::YELLOW)
  end
end

# Inicia o jogo
CarRaceGame.new.show