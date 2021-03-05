(in-package p180221044-180221045)

;;;; interact.lisp
;;;; Disciplina de IA - 2020 / 2021
;;;; Problema do Quatro -  2ª parte do projeto de Inteligência Artificial.
;;;; Autores: Ricardo Lopes 180221044, Rui Silva 180221045 

;;Variável global do caminho base
(defparameter *base_path* "C:/Users/Rui/Desktop/RicardoLopes_180221044_RuiSilva_180221045_P2/")

;;Função que recebe uma lista e escreve o conteúdo da mesma para um ficheiro no caso de sucesso.
(defun escrever-ficheiro (lista)
  (if (null
       (with-open-file (str (format nil "~Alog.dat" *base_path*)
                            :direction :output
                            :if-exists :append
                            :if-does-not-exist :create)
         (format str "Jogada ~A~%" (first lista))
         (format str "~A~%" (second lista))
         (format str "Nº de nós analisados: ~A~%" (third lista))
         (format str "Nº de cortes efetuados: ~A~%" (fourth lista))
         (format str "Tempo gasto: ~A ms~%~%" (fifth lista))
         )) (format t "~%Sucesso a escrever para ficheiro~%") (format t "Erro a escrever para ficheiro"))
  )

;;Função que permite que o utilizador escolha um dos modos de jogo (humano vs computador ou computador vs computador).
(defun jogo()
  (menu-inicial)
  (let ((opcao (read)))
    (cond 
     ((= opcao 1) (iniciar))
     ((= opcao 2) (iniciar-computadores))
     ((= opcao 0) (format t "Adeus!"))
     (t (jogo))
     )
    )
  )

;;Função da interação do utilizador com a interface da escolha inicial.
(defun menu-inicial()
  (format t "~%           Jogo do Quatro")
  (format t "~%========================================")
  (format t "~%         Seja bem-vindo!")
  (format t "~%         1 - Jogar Humano vs Computador!")
  (format t "~%         2 - Jogar Computador vs Computador!")
  (format t "~%         0 - Sair~%>")
  )

;;Função que permite guardar a profundidade, tempo limite e quem começa o jogo para posteriormente o iniciar (modo humano vs computador).
(defun iniciar()
  (format t "Quem é que começa?[H - Humano] [C - Computador]~%>")
  (let ((jogador (read)) (profundidade (progn (format t "~%Qual é o limite de profundidade?[1-5]~%>")(read))) (limite-tempo (progn (format t "~%Qual é o limite de tempo máximo?[1000-5000 ms]~%>") (read))))
    (cond
     ((or (and (not (eq jogador 'H)) (not (eq jogador 'C))) (< profundidade 0) (< limite-tempo 1000) (> limite-tempo 5000)) (iniciar))
     ((eq jogador 'H) (comecar-a-jogar (no-inicial) 'H profundidade limite-tempo))
     (t (comecar-a-jogar (no-inicial) 'C profundidade (/ limite-tempo 1000)))
     )
    )
  )

;;Função que permite guardar o tempo limite para posteriormente iniciar o modo computador vs computador.
(defun iniciar-computadores()
  (let ((profundidade (progn (format t "~%Qual é o limite de profundidade?[1-5]~%>")(read))) (limite-tempo (progn (format t "~%Qual é o limite de tempo máximo?[1000-5000 ms]~%>") (read))))
    (cond
     ((or (< profundidade 0) (< limite-tempo 1000) (> limite-tempo 5000)) (iniciar-computadores))
     (t (computador-vs-computador (no-inicial) 1 profundidade (/ limite-tempo 1000)))
     )
    )
  )

;;Função que implementa o modo computador vs computador, começa por imprimir o tabuleiro atual , limpa as estatisticas e a jogada anterior. Apenas iremos pedir a profundidade e o tempo limite ao utilizador inicialmente e, a partir desse momento os computadores irão jogar automaticamente.
(defun computador-vs-computador(no primeiro profundidade-limite tempo-limite)
  (imprime-jogo no)
  (reset-jogada-nos)
  (cond 
   ((tabuleiro-preenchidop (tabuleiro no)) (format t "~%~%Empataram!"))
   ((and (no-solucaop no) (eq primeiro 1)) (format t "~%~%O computador 2 ganhou!"))
   ((and (no-solucaop no) (eq primeiro 2)) (format t "~%~%O computador 1 ganhou!"))
   ((= primeiro 1)  (progn (alfabeta no tempo-limite profundidade-limite) (mostrar-estatisticas 0) (escrever-ficheiro (append '("Computador 1") (list (first *jogada*)) *lista-nos*)) (cond ((computador-perde) (format t "~%~%O computador 2 ganhou!")) (t (computador-vs-computador (cria-no (no-jogo (first *jogada*))) 2 profundidade-limite tempo-limite)))))
   ((= primeiro 2) (progn (alfabeta no tempo-limite profundidade-limite) (mostrar-estatisticas 0) (escrever-ficheiro (append '("Computador 2") (list (first *jogada*)) *lista-nos*)) (cond ((computador-perde) (format t "~%~%O computador 1 ganhou!")) (t (computador-vs-computador (cria-no (no-jogo (first *jogada*))) 1 profundidade-limite tempo-limite)))))
   )
)

;;Função que implementa o modo humano vs computador, começa por imprimir o tabuleiro atual , limpa as estatisticas e a jogada anterior. Se o humano for o primeiro então irá pedir as informações da jogada a realizar e irá tanto escrever para o ficheiro como seguir para o computador caso contrário, o computador começa primeiro. 
(defun comecar-a-jogar(no primeiro profundidade-limite tempo-limite)
  (imprime-jogo no)
  (reset-jogada-nos)
  (cond 
   ((tabuleiro-preenchidop (tabuleiro no)) (format t "~%~%Empataram!"))
   ((and (no-solucaop no) (eq primeiro 'H)) (format t "~%~%O computador ganhou!"))
   ((and (no-solucaop no) (eq primeiro 'C)) (format t "~%~%Ganhaste!"))
   ((eq primeiro 'H)  (let ((novo-no (jogada-humana no))) (progn (escrever-ficheiro (list "Humano" novo-no 0 0 0)) (comecar-a-jogar novo-no 'C profundidade-limite tempo-limite)))) 
   ((eq primeiro 'C) (progn (alfabeta no tempo-limite profundidade-limite) (mostrar-estatisticas 0) (escrever-ficheiro (append '("Computador") (list (first *jogada*)) *lista-nos*)) (cond ((computador-perde) (format t "~%~%Ganhaste!")) (t (comecar-a-jogar (cria-no (no-jogo (first *jogada*))) 'H profundidade-limite tempo-limite))))
   )
  )
)

;;Função que mostra as estatísticas de cada jogada.
(defun mostrar-estatisticas(tempo)
 (format t "~%Nº de nós analisados: ~A~%Nº de cortes efetuados: ~A~%Tempo gasto: ~A ms~%~%" (first *lista-nos*) (second *lista-nos*) tempo)
)

;;Função que limpa a lista de nós(analisados e cortados) e a melhor jogada para que na próxima análise a jogada seja guardada.
(defun reset-jogada-nos()
  (setf *lista-nos* (list 0 0))
  (setf *jogada* (list nil *menosinfinito*))
)

;;Função que verifica se o computador perdeu ou não. Retorna T se não for encontrada uma jogada a tempo quando é invocado o alfabeta e nil caso contrário.
(defun computador-perde()
  (cond ((null (first *jogada*)) t)
        (t nil)
        )
  )

;;Função que pede ao utilizador uma coluna, uma linha e a posição da peça nas reservas. Retorna o tabuleiro com a nova peça escolhida na posição [colunalinha].
(defun jogada-humana (no)
  (format t "~%=====================~%Humano~%")
  (let ((coluna (progn (format t"Introduz a coluna [A-D]~%>")(traduzir-coluna (read)))) (linha (progn (format t "Introduz a linha [1-4]~%>")(read))) (peca (progn (format t "Introduz a posição da peça[1-~A]~%>" (length (reserva no)))(read)))) 
    (cond 
     ((< (1- peca) 0) (progn (format t "Posição da reserva inválida.")  (jogada-humana no)))
     ((null (nth (1- peca) (reserva no))) (progn (format t "Peça não existe nas reservas.")  (jogada-humana no)))
     ((null (substituir (1- linha) coluna (nth (1- peca) (reserva no)) (tabuleiro no))) (progn (format t "Coluna ou linha inválidas")  (jogada-humana no)))
     (t (cria-no (cons (substituir (1- linha) coluna (nth (1- peca) (reserva no)) (tabuleiro no)) (cons (remover-peca (nth (1- peca) (reserva no)) (reserva no)) nil)) 0))
     )
    )
  )

;;Função que traduz o valor introduzido pelo utilizador. Retorna o respetivo valor numérico caso senão retorna 4.
(defun traduzir-coluna(valor)
  (cond 
   ((eq valor 'A) 0)
   ((eq valor 'B) 1)
   ((eq valor 'C) 2)
   ((eq valor 'D) 3)
   (t 4)
   )
  )

;;Função que mostra o tabuleiro e as reservas do nó passado por parâmetros.
(defun imprime-jogo(no)
  (format t "~%~%=====================~%Tabuleiro~%" )
  (imprimir (tabuleiro no))
  (format t "~%Reservas~%" )
  (imprimir (reserva no))
  )

;;Função que imprime as linhas uma a uma da PARTE(tabuleiro ou reservas) para o ecrã, recursivamente.
(defun imprimir(parte)
  (cond
   ((null parte) (format t ""))
   (t (progn (format t "~A~%" (car parte)) (imprimir (cdr parte))))
   )
  )

;;Função que cria o nó inicial utilizado para começar um jogo.
(defun no-inicial()
  (cria-no (jogo-inicial))
  )

;;Função que retorna o jogo correspondente ao nó inicial.
(defun jogo-inicial()
  '(
    (
     (0 0 0 0) (0 0 0 0) (0 0 0 0) (0 0 0 0)
     )
    (
     (branca redonda alta oca)
     (preta redonda alta oca)
     (branca redonda baixa oca)
     (preta redonda baixa oca)
     (branca quadrada alta oca)
     (preta quadrada alta oca)
     (branca quadrada baixa oca)
     (preta quadrada baixa oca)
     (branca redonda alta cheia)
     (preta redonda alta cheia)
     (branca redonda baixa cheia)
     (preta redonda baixa cheia)
     (branca quadrada alta cheia)
     (preta quadrada alta cheia)
     (branca quadrada baixa cheia)
     (preta quadrada baixa cheia)
     )
    )
  )
