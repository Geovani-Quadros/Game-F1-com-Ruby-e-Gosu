# Importando a biblioteca Gosu
require 'gosu'

# Classe Player, que representa o jogador
class Player
  attr_accessor :x, :y, :tamanho, :velocidade

  def initialize(x, y, tamanho, velocidade)
    @x = x
    @y = y
    @tamanho = tamanho
    @velocidade = velocidade
  end

  # Método para movimentar o jogador
  def mover
    if Gosu.button_down?(Gosu::KB_LEFT)
      @x -= @velocidade
    elsif Gosu.button_down?(Gosu::KB_RIGHT)
      @x += @velocidade
    end

    if Gosu.button_down?(Gosu::KB_UP)
      @y -= @velocidade
    elsif Gosu.button_down?(Gosu::KB_DOWN)
      @y += @velocidade
    end
  end

  # Método para desenhar o jogador na tela
  def draw
    Gosu.draw_rect(@x, @y, @tamanho, @tamanho, Gosu::Color::RED)
  end

  # Método para verificar colisão com outro retângulo (como oponente)
  def colidiu_com?(outro)
    (@x < outro.x + outro.tamanho) && (@x + @tamanho > outro.x) &&
      (@y < outro.y + outro.tamanho) && (@y + @tamanho > outro.y)
  end
end

# Classe Oponente, que representa os oponentes no jogo
class Oponente
  attr_accessor :x, :y, :tamanho, :velocidade

  def initialize(x, y, tamanho, velocidade)
    @x = x
    @y = y
    @tamanho = tamanho
    @velocidade = velocidade
  end

  # Método para movimentação simples do oponente (movimento aleatório)
  def mover
    direcao = rand(4)

    case direcao
    when 0
      @x -= @velocidade  # Esquerda
    when 1
      @x += @velocidade  # Direita
    when 2
      @y -= @velocidade  # Cima
    when 3
      @y += @velocidade  # Baixo
    end
  end

  # Método para desenhar o oponente na tela
  def draw
    Gosu.draw_rect(@x, @y, @tamanho, @tamanho, Gosu::Color::BLUE)
  end
end

# Classe principal do jogo
class Jogo < Gosu::Window
  def initialize
    # Inicializa a janela do jogo
    super 640, 480
    self.caption = 'Jogo com Jogador e Oponentes'

    # Tela de menu para escolher a dificuldade
    @menu = true

    # Variáveis de jogo
    @dificuldade = nil
    @player = nil
    @oponentes = []
    @game_over = false  # Flag para verificar se o jogo terminou
  end

  # Atualiza o estado do jogo a cada quadro
  def update
    if @menu
      # Espera a escolha do usuário no menu
      if Gosu.button_down?(Gosu::KB_E)
        escolher_dificuldade('easy')
      elsif Gosu.button_down?(Gosu::KB_M)
        escolher_dificuldade('medium')
      elsif Gosu.button_down?(Gosu::KB_H)
        escolher_dificuldade('hard')
      end
    elsif @game_over
      # Não faz nada se o jogo estiver em Game Over
      return
    else
      # Atualiza o movimento do jogador
      @player.mover

      # Atualiza o movimento de cada oponente
      @oponentes.each { |oponente| oponente.mover }

      # Verifica colisão entre o jogador e cada oponente
      @oponentes.each do |oponente|
        if @player.colidiu_com?(oponente)
          # Se houver colisão, o jogo termina
          game_over
        end
      end
    end
  end

  # Desenha os objetos na tela
  def draw
    if @menu
      # Exibe o menu de escolha de dificuldade
      exibir_menu
    elsif @game_over
      # Exibe a tela de Game Over
      exibir_game_over
    else
      # Desenha o jogador
      @player.draw

      # Desenha todos os oponentes
      @oponentes.each { |oponente| oponente.draw }
    end
  end

  # Método para exibir o menu de escolha de dificuldade
  def exibir_menu
    font = Gosu::Font.new(self, Gosu.default_font_name, 32)
    font.draw_text("Escolha a dificuldade", 150, 100, 1, 1, 1, Gosu::Color::WHITE)
    font.draw_text("Pressione E para Easy", 150, 200, 1, 1, 1, Gosu::Color::WHITE)
    font.draw_text("Pressione M para Medium", 150, 250, 1, 1, 1, Gosu::Color::WHITE)
    font.draw_text("Pressione H para Hard", 150, 300, 1, 1, 1, Gosu::Color::WHITE)
  end

  # Método para exibir a tela de Game Over
  def exibir_game_over
    font = Gosu::Font.new(self, Gosu.default_font_name, 48)
    font.draw_text("GAME OVER!", 200, 200, 1, 1, 1, Gosu::Color::RED)
    font.draw_text("Pressione R para reiniciar", 150, 300, 1, 1, 1, Gosu::Color::WHITE)
  end

  # Método para escolher a dificuldade e iniciar o jogo
  def escolher_dificuldade(dificuldade)
    @menu = false
    @dificuldade = dificuldade

    # Cria uma instância do jogador
    @player = Player.new(320, 240, 50, 5)

    # Define a quantidade e velocidade dos oponentes com base na dificuldade
    case @dificuldade
    when 'easy'
      criar_oponentes(2, 2)
    when 'medium'
      criar_oponentes(4, 4)
    when 'hard'
      criar_oponentes(6, 6)
    end
  end

  # Método para criar oponentes com base na dificuldade
  def criar_oponentes(quantidade, velocidade)
    @oponentes.clear
    quantidade.times do
      x = rand(640)
      y = rand(480)
      oponente = Oponente.new(x, y, 40, velocidade)
      @oponentes << oponente
    end
  end

  # Método para finalizar o jogo e exibir a tela de Game Over
  def game_over
    @game_over = true
  end

  # Reiniciar o jogo ao pressionar a tecla R
  def button_down(id)
    if id == Gosu::KB_R && @game_over
      reiniciar_jogo
    end
  end

  # Método para reiniciar o jogo
  def reiniciar_jogo
    @game_over = false
    escolher_dificuldade(@dificuldade)  # Reinicia o jogo com a mesma dificuldade
  end
end

# Cria uma instância do jogo e inicia a janela
Jogo.new.show
