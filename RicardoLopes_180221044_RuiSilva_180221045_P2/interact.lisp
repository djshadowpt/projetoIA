(in-package p180221044-180221045)

;;;; interact.lisp
;;;; Disciplina de IA - 2020 / 2021
;;;; Problema do Quatro -  2� parte do projeto de Intelig�ncia Artificial.
;;;; Autores: Ricardo Lopes 180221044, Rui Silva 180221045 

;;Vari�vel global do caminho base
(defparameter *base_path* "C:/Users/Rui/Desktop/RicardoLopes_180221044_RuiSilva_180221045_P2/")

;;Fun��o que recebe uma lista e escreve o conte�do da mesma para um ficheiro no caso de sucesso.
(defun escrever-ficheiro (lista)
  (if (null
       (with-open-file (str (format nil "~Alog.dat" *base_path*)
                            :direction :output
                            :if-exists :append
                            :if-does-not-exist :create)
         (format str "Jogada ~A~%" (first lista))
         (format str "~A~%" (second lista))
         (format str "N� de n�s analisados: ~A~%" (third lista))
         (format str "N� de cortes efetuados: ~A~%" (fourth lista))
         (format str "Tempo gasto: ~A ms~%~%" (fifth lista))
         )) (format t "~%Sucesso a escrever para ficheiro~%") (format t "Erro a escrever para ficheiro"))
  )

;;Fun��o que permite que o utilizador escolha um dos modos de jogo (humano vs computador ou computador vs computador).
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

;;Fun��o da intera��o do utilizador com a interface da escolha inicial.
(defun menu-inicial()
  (format t "~%           Jogo do Quatro")
  (format t "~%========================================")
  (format t "~%         Seja bem-vindo!")
  (format t "~%         1 - Jogar Humano vs Computador!")
  (format t "~%         2 - Jogar Computador vs Computador!")
  (format t "~%         0 - Sair~%>")
  )

;;Fun��o que permite guardar a profundidade, tempo limite e quem come�a o jogo para posteriormente o iniciar (modo humano vs computador).
(defun iniciar()
  (format t "Quem � que come�a?[H - Humano] [C - Computador]~%>")
  (let ((jogador (read)) (profundidade (progn (format t "~%Qual � o limite de profundidade?[1-5]~%>")(read))) (limite-tempo (progn (format t "~%Qual � o limite de tempo m�ximo?[1000-5000 ms]~%>") (read))))
    (cond
     ((or (and (not (eq jogador 'H)) (not (eq jogador 'C))) (< profundidade 0) (< limite-tempo 1000) (> limite-tempo 5000)) (iniciar))
     ((eq jogador 'H) (comecar-a-jogar (no-inicial) 'H profundidade limite-tempo))
     (t (comecar-a-jogar (no-inicial) 'C profundidade (/ limite-tempo 1000)))
     )
    )
  )

;;Fun��o que permite guardar o tempo limite para posteriormente iniciar o modo computador vs computador.
(defun iniciar-computadores()
  (let ((profundidade (progn (format t "~%Qual � o limite de profundidade?[1-5]~%>")(read))) (limite-tempo (progn (format t "~%Qual � o limite de tempo m�ximo?[1000-5000 ms]~%>") (read))))
    (cond
     ((or (< profundidade 0) (< limite-tempo 1000) (> limite-tempo 5000)) (iniciar-computadores))
     (t (computador-vs-computador (no-inicial) 1 profundidade (/ limite-tempo 1000)))
     )
    )
  )

;;Fun��o que implementa o modo computador vs computador, come�a por imprimir o tabuleiro atual , limpa as estatisticas e a jogada anterior. Apenas iremos pedir a profundidade e o tempo limite ao utilizador inicialmente e, a partir desse momento os computadores ir�o jogar automaticamente.
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

;;Fun��o que implementa o modo humano vs computador, come�a por imprimir o tabuleiro atual , limpa as estatisticas e a jogada anterior. Se o humano for o primeiro ent�o ir� pedir as informa��es da jogada a realizar e ir� tanto escrever para o ficheiro como seguir para o computador caso contr�rio, o computador come�a primeiro. 
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

;;Fun��o que mostra as estat�sticas de cada jogada.
(defun mostrar-estatisticas(tempo)
 (format t "~%N� de n�s analisados: ~A~%N� de cortes efetuados: ~A~%Tempo gasto: ~A ms~%~%" (first *lista-nos*) (second *lista-nos*) tempo)
)

;;Fun��o que limpa a lista de n�s(analisados e cortados) e a melhor jogada para que na pr�xima an�lise a jogada seja guardada.
(defun reset-jogada-nos()
  (setf *lista-nos* (list 0 0))
  (setf *jogada* (list nil *menosinfinito*))
)

;;Fun��o que verifica se o computador perdeu ou n�o. Retorna T se n�o for encontrada uma jogada a tempo quando � invocado o alfabeta e nil caso contr�rio.
(defun computador-perde()
  (cond ((null (first *jogada*)) t)
        (t nil)
        )
  )

;;Fun��o que pede ao utilizador uma coluna, uma linha e a posi��o da pe�a nas reservas. Retorna o tabuleiro com a nova pe�a escolhida na posi��o [colunalinha].
(defun jogada-humana (no)
  (format t "~%=====================~%Humano~%")
  (let ((coluna (progn (format t"Introduz a coluna [A-D]~%>")(traduzir-coluna (read)))) (linha (progn (format t "Introduz a linha [1-4]~%>")(read))) (peca (progn (format t "Introduz a posi��o da pe�a[1-~A]~%>" (length (reserva no)))(read)))) 
    (cond 
     ((< (1- peca) 0) (progn (format t "Posi��o da reserva inv�lida.")  (jogada-humana no)))
     ((null (nth (1- peca) (reserva no))) (progn (format t "Pe�a n�o existe nas reservas.")  (jogada-humana no)))
     ((null (substituir (1- linha) coluna (nth (1- peca) (reserva no)) (tabuleiro no))) (progn (format t "Coluna ou linha inv�lidas")  (jogada-humana no)))
     (t (cria-no (cons (substituir (1- linha) coluna (nth (1- peca) (reserva no)) (tabuleiro no)) (cons (remover-peca (nth (1- peca) (reserva no)) (reserva no)) nil)) 0))
     )
    )
  )

;;Fun��o que traduz o valor introduzido pelo utilizador. Retorna o respetivo valor num�rico caso sen�o retorna 4.
(defun traduzir-coluna(valor)
  (cond 
   ((eq valor 'A) 0)
   ((eq valor 'B) 1)
   ((eq valor 'C) 2)
   ((eq valor 'D) 3)
   (t 4)
   )
  )

;;Fun��o que mostra o tabuleiro e as reservas do n� passado por par�metros.
(defun imprime-jogo(no)
  (format t "~%~%=====================~%Tabuleiro~%" )
  (imprimir (tabuleiro no))
  (format t "~%Reservas~%" )
  (imprimir (reserva no))
  )

;;Fun��o que imprime as linhas uma a uma da PARTE(tabuleiro ou reservas) para o ecr�, recursivamente.
(defun imprimir(parte)
  (cond
   ((null parte) (format t ""))
   (t (progn (format t "~A~%" (car parte)) (imprimir (cdr parte))))
   )
  )

;;Fun��o que cria o n� inicial utilizado para come�ar um jogo.
(defun no-inicial()
  (cria-no (jogo-inicial))
  )

;;Fun��o que retorna o jogo correspondente ao n� inicial.
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
