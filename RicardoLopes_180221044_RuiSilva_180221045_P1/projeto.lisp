;;;; projeto.lisp
;;;; Disciplina de IA - 2020 / 2021
;;;; Problema do Quatro -  1ª parte do projeto de Inteligência Artificial.
;;;; Autores: Ricardo Lopes 180221044, Rui Silva 180221045 


;;Função que recebe um nó, uma lista dos nós expandidos e dos gerados e devolve a avaliação do desempenho de um algoritmo.
(defun mostrar-solucao (no expandidos gerados tempo nomeficheiro &aux (penetrancia (/ (no-profundidade no) gerados)))
  (escrever-ficheiro (list no expandidos gerados (ramificacao no gerados) penetrancia tempo) nomeficheiro)
)

;;Função que recebe uma lista e escreve o conteúdo da mesma para um ficheiro no caso de sucesso.
(defun escrever-ficheiro (lista nomeficheiro)
  (if (null
       (with-open-file (str (format nil "~Asolucao~A.txt" *base_path* nomeficheiro)
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
         (format str "Nó solução: ~A~%" (first lista))
         (format str "Nº de nós expandidos: ~A~%" (second lista))
         (format str "Nº de nós gerados: ~A~%" (third lista))
         (format str "Fator de ramificação: ~A~%" (fourth lista))
         (format str "Penetrância: ~A~%" (fifth lista))
         (format str "Tempo de execução: ~A s~%" (sixth lista)))
       ) (retomar-jogo nomeficheiro) (format t "Erro a escrever ficheiro"))
  )

;;Função que retorna ao menu inicial do jogo após a escrita do ficheiro com sucesso. Apresenta a mensagem final.
(defun retomar-jogo (nomeficheiro)
(format t "Sucesso a escrever para ficheiro solucao~A.txt" nomeficheiro)
(iniciar)
)

;;Variável global do caminho base
(defparameter *base_path* "C:/Users/lkrak/Desktop/RicardoLopes_180221044_RuiSilva_180221045_P1/")

;;Função que recebe o caminho do ficheiro e devolve uma lista com todos os tabuleiros do ficheiro.
(defun escolher-ficheiro(caminho)
  (with-open-file (f caminho
                      :direction :input 
                      :if-does-not-exist nil)
    (ler-ficheiro f)
    )
)

;;Função que recebe um ficheiro com tabuleiros (F) e constrói uma lista com todos os tabuleiros do ficheiro. 
(defun ler-ficheiro(f &optional (tabuleiros '()))
  (let* ((tabuleiro (read f nil :end)) 
         (tabuleiros(cons tabuleiro tabuleiros)))
    (cond
     ((equal tabuleiro :end) (reverse (cdr tabuleiros)))
     (t (ler-ficheiro f tabuleiros))
     )
    )
)

;;Função que permite que o utilizador comece a jogar ou que visualize os tabuleiros.
(defun jogar()
(menu-inicial)
  (let ((opcao (read)))
    (cond 
     ((= opcao 1) (iniciar))
     ((= opcao 2) (escolher-tabuleiro))
     ((= opcao 0) (format t "Adeus!"))
     (t (jogar))
    )
    )
)
 
;;Função da interação do utilizador com a interface da escolha inicial.
(defun menu-inicial()
  (format t "~%           Jogo do Quatro")
  (format t "~%========================================")
  (format t "~%         Seja bem-vindo!")
  (format t "~%         1 - Jogar!")
  (format t "~%         2 - Mostrar tabuleiros")
  (format t "~%         0 - Sair~%>")
)


;;Função para registar a escolha do utilizador acerca do algoritmo a utilizar.
(defun iniciar()
  (menu-algoritmo)
  (let ((opcao (read)))
    (cond 
     ((= opcao 1) (escolher-problema 'bfs))
     ((= opcao 2) (escolher-profundidade 'dfs))
     ((= opcao 3) (escolher-heuristica 'astar))
     ((= opcao 4) (escolher-heuristica 'idastar))
     ((= opcao 0) (jogar))
     (t (iniciar))
    )
    )
)

;;Função da interação do utilizador com a interface para a escolha do algoritmo a utlizar.
(defun menu-algoritmo()
  (format t "~%           Jogo do Quatro")
  (format t "~%========================================")
  (format t "~%         Escolha o algoritmo")
  (format t "~%         1 - Breadth-First Search")
  (format t "~%         2 - Depth-First Search")
  (format t "~%         3 - A* Search ")
  (format t "~%         4 - IDA* Search")
  (format t "~%         0 - Sair~%>")
)

;;Função que recebe o algoritmo a utilizar e escreve para um ficheiro o resultado da aplicação do algoritmo.
(defun escolher-problema(algoritmo &optional (profundidade 9999))
    (menu-problemas)
    (let* ((opcao (read)) 
           (problemas (escolher-ficheiro (format nil "~Aproblemas.dat" *base_path*)))
           )
      (cond 
       ((= opcao 0) (iniciar))
       ((or (< opcao 0) (> opcao 6)) (escolher-problema algoritmo profundidade))
       (t 
        (cond
         ((equal algoritmo 'dfs) (funcall algoritmo (cria-no (nth (1- opcao) problemas)) 'no-solucaop 'sucessores profundidade (concatenate 'string (string algoritmo) "_" (letra opcao)))) 
         ((equal algoritmo 'idastar) (funcall algoritmo (cria-no (nth (1- opcao) problemas)) 'no-solucaop 'sucessores (custo (cria-no (nth (1- opcao) problemas))) (concatenate 'string (string algoritmo) "_" (letra opcao))))
         (t (funcall algoritmo (cria-no (nth (1- opcao) problemas)) 'no-solucaop 'sucessores (concatenate 'string (string algoritmo) "_" (letra opcao)))))
        )
       )
      )
)

;;Função da interação do utilizador com a interface para a escolha dos problemas dos tabuleiros.
(defun menu-problemas()
  (format t "~%           Jogo do Quatro")
  (format t "~%========================================")
  (format t "~%         Escolha o tabuleiro")
  (format t "~%         1 - Tabuleiro A")
  (format t "~%         2 - Tabuleiro B")
  (format t "~%         3 - Tabuleiro C")
  (format t "~%         4 - Tabuleiro D")
  (format t "~%         5 - Tabuleiro E")
  (format t "~%         6 - Tabuleiro F")
;;  (format t "~%         7 - Tabuleiro G")
  (format t "~%         0 - Voltar~%>")
)

;;Função para registar a escolha do utilizador acerca do tabuleiro que quer visualizar.
(defun escolher-tabuleiro()
(menu-problemas)
(let* ((opcao (read)) 
           (problemas (escolher-ficheiro (format nil "~Aproblemas.dat" *base_path*))))
      (cond 
       ((= opcao 0) (jogar))
       ((or (< opcao 0) (> opcao 6)) (escolher-tabuleiro))
       (t (mostrar-tabuleiro opcao problemas))
      )
)
)

;;Função que imprime o tabuleiro escolhido pelo utilizador.
(defun mostrar-tabuleiro(opcao problemas)
 (format t "Tabuleiro ~A~%~A~%" (letra opcao) (nth (1- opcao) problemas)) 
 (escolher-tabuleiro)
)

;;Função que recebe um NUMERO e devolve a letra do tabuleiro correspondente à opção escolhida.
(defun letra (numero)
  (cond
   ((= numero 1) "A")
   ((= numero 2) "B")
   ((= numero 3) "C")
   ((= numero 4) "D")
   ((= numero 5) "E")
   ((= numero 6) "F")
;;   ((= numero 7) "G")
   (t nil)
   )
)

;;Função da interação do utilizador com a interface para a escolha da heuristica a utlizar.
(defun menu-heuristica()
  (format t "~%           Jogo do Quatro")
  (format t "~%========================================")
  (format t "~%         Escolha a heurística")
  (format t "~%         1 - Heurística Enunciado")
  (format t "~%         0 - Voltar~%>")
)

;;Função para registar a escolha do utilizador acerca da heuristica.
(defun escolher-heuristica(algoritmo)
  (menu-heuristica)
  (let ((opcao (read)))
    (cond 
     ((= opcao 1) (escolher-problema algoritmo))
     ((= opcao 0) (iniciar))
     (t (escolher-heuristica algoritmo))
     )
    )
)

;;Função da interação do utilizador com a interface para a escolha da profundidade máxima a utilizar.
(defun menu-profundidade()
  (format t "~%           Jogo do Quatro")
  (format t "~%========================================")
  (format t "~%    Escolha a profundidade máxima")
  (format t "~%    -1 - Voltar~%>")
)

;;Função para registar a escolha do utilizador acerca da profundidade máxima.
(defun escolher-profundidade(algoritmo)
  (menu-profundidade)
  (let ((profundidade (read)))
    (cond
     ((< profundidade -1) (escolher-profundidade algoritmo))
     ((= profundidade -1) (iniciar))
     (t (escolher-problema algoritmo profundidade))
     )
    )
)
















