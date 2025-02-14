require 'gosu'

class Player
  attr_reader :player_x, :player_y, :vel_car, :collision_x, :collision_y

  def initialize
    @player_car_image = Gosu::Image.new("images/player_car.png")
    @player_x = 250
    @player_y = 315
    @vel_car = 5
    @width = 80
    @height = 205
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
      
      # Calcular os pontos de colisão (pode ser ajustado conforme a necessidade)
      @collision_x = (@player_x + obstaculo.x) / 2
      #@collision_y = obstaculo.y + (obstaculo.height / 2)
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

  def initialize(janela_x)
    @width = 50 #largura do cone: 50px
    @height = 60 #altura do cone: 60px
    @x = rand(janela_x - @width)
    @y = - (@height)
    @obstacles_image = Gosu::Image.new("images/obstacle.png")
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
    @vel_car_obs = 5

    super @janela_x, @janela_y, false
    self.caption = "Jogo Treino F1 2D em Ruby"

    @car = nil
    @cont_cone = 1
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
    # Adiciona novos obstáculos a cada 1000 milissegundos
    @obstacle_timer += 3
    if @obstacle_timer > 100
      @obstacles << Obstaculos.new(@janela_x)
      @cont_cone += 1
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
      @car = Player.new()
      @obstacles << Obstaculos.new(@janela_x)
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