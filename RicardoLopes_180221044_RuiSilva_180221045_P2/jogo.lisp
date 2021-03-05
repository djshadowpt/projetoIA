(defpackage :p180221044-180221045)
(in-package p180221044-180221045) 

;;;; jogo.lisp
;;;; Disciplina de IA - 2020 / 2021
;;;; Problema do Quatro -  2� parte do projeto de Intelig�ncia Artificial.
;;;; Autores: Ricardo Lopes 180221044, Rui Silva 180221045 

;;Vari�vel global da lista de n�s (analisados cortados)
(defvar *lista-nos* (list 0 0 0))

;;Vari�vel global que define o menor valor poss�vel
(defvar *menosinfinito* most-negative-fixnum)

;;Vari�vel global que define o maior valor poss�vel
(defvar *maisinfinito* most-positive-fixnum)

;;Vari�vel global que define a melhor jogada atual e o valor da avalia��o
(defvar *jogada* (list nil *menosinfinito*))


;;===================Seletores================
;;Fun��o que recebe uma lista que cont�m um tabuleiro com reservas de pe�a e devolve o tabuleiro
(defun tabuleiro (no)
  (caar no)
  )

;;Fun��o que recebe uma lista que cont�m um tabuleiro com reservas de pe�a e devolve a reserva de pe�as
(defun reserva (no)
  (cadar no)
  )

;;Fun��o que recebe um �ndice e o tabuleiro e retorna uma lista que representa essa linha do tabuleiro.
(defun linha (indice tabuleiro)
  (cond ((or (< indice 0) (null tabuleiro)) nil)
        ((zerop indice) (car tabuleiro))
        (t (linha (1- indice) (cdr tabuleiro)))
        )
  )

;;Fun��o que recebe um �ndice e o tabuleiro e retorna uma lista que representa essa coluna do tabuleiro.
(defun coluna (indice tabuleiro)
  (cond ((or (< indice 0) (null tabuleiro)) nil)
        (t (maplist #'(lambda (linhaTabuleiro &aux (cabeca (linha indice (car linhaTabuleiro)))) cabeca) tabuleiro))
        )
  )

;;Fun��o que recebe dois �ndices (linha e coluna) e o tabuleiro e retorna o valor presente nessa c�lula do tabuleiro.
(defun celula (linhaTabuleiro colunaTabuleiro tabuleiro)
  (linha linhaTabuleiro (coluna colunaTabuleiro tabuleiro))
  )

;;Fun��o que recebe um tabuleiro e retorna uma lista que representa uma diagonal desse tabuleiro. Considere a diagonal-1 como a diagonal a come�ar pela c�lula na 1� linha e 1� coluna.
(defun diagonal-1 (tabuleiro) 
  (maplist #'(lambda (tabuleiroParte &aux (tamanho (- (length tabuleiro) (length tabuleiroParte)))) (celula tamanho tamanho tabuleiro)) tabuleiro)
  )

;;Fun��o que recebe um tabuleiro e retorna uma lista que representa uma diagonal desse tabuleiro. Considere a diagonal-2 como a diagonal a come�ar pela c�lula na �ltima linha e 1� coluna.
(defun diagonal-2 (tabuleiro) 
  (maplist #'(lambda (tabuleiroParte &aux (tamanho (- (length tabuleiro) (length tabuleiroParte)))) (celula (1- (length tabuleiroParte)) tamanho tabuleiro)) tabuleiro)
  )

;;Fun��o quer recebe um n� e retorna o jogo (tabuleiro e as reservas).
(defun no-jogo (no)
  (car no)
  )

;;Fun��o que recebe um n� e retorna a profundidade do n�.
(defun no-profundidade (no)
  (cadr no)
  )

;;Fun��o que verifica se o tabuleiro do jogo est� ou n�o preenchido para verifica��o do empate.
(defun tabuleiro-preenchidop(tabuleiro)
  (cond 
   ((null tabuleiro) t)
   ((find '0 (car tabuleiro)) nil)
   (t (tabuleiro-preenchidop (cdr tabuleiro)))
   )
  )

;;=================Construtor=====================
;;Fun��o que recebe um jogo (tabuleiro e reservas) e devolve um n� que � uma lista do jogo, da profundidade e do pai do n� inicial.
(defun cria-no (jogo &optional (g 0))
  (list jogo g)
  )

;;===============Fun��o avalia��o==============

;;Fun��o que recebe um tabuleiro e devolve o valor dessa avalia��o.
(defun funcao-avaliacao(tabuleiro)
  (apply '+ (append (mapcar #'(lambda (linha) (pontuar-lista (propriedade-comum linha))) tabuleiro)

                    (maplist #'(lambda (tabuleiroParte &aux (tamanho (- (length tabuleiro) (length tabuleiroParte))))  (pontuar-lista (propriedade-comum (coluna tamanho tabuleiro)))) tabuleiro)
                   
                    (list (pontuar-lista (propriedade-comum (diagonal-1 tabuleiro)))

                          (pontuar-lista (propriedade-comum (diagonal-2 tabuleiro))))
                    )
         )
  )

;;Fun��o que traduz a pontua��o de cada elemento de uma lista de avalia��o de um estado.
(defun pontuar-lista(elemento)
  (cond ((= elemento 4) 100) ((= elemento 3) -50) ((= elemento 2) 10) ((= elemento 1) 1) (t 0))
  )

;;Fun��o que recebe uma pe�a e uma lista e devolve o n�mero m�ximo de propriedades em comum de uma pe�a com outras da lista.
(defun propriedade-comum (lista &optional (x 0) (redutora (alisa lista)) (alisada (alisa lista)))
  (cond 
   ((null redutora) x)
   (t (propriedade-comum lista (max x (propriedadep (car redutora) alisada)) (cdr redutora)))
   )
  )

;;=================Fun��es auxiliares para c�lculo dos sucessores e verifica��o da solu��o==================
;;Fun��o que recebe um tabuleiro, uma peca, uma fun��o de pesquisa (f-pesquisa) e opcionalmente um indice e devolve o indice onde a peca se encontra e NIL caso a peca n�o exista. 
(defun encontrar-peca (tabuleiro peca f-pesquisa &optional (indice (1- (length tabuleiro))))
  (cond
   ((< indice 0) nil)
   ((peca-existep peca (funcall f-pesquisa indice tabuleiro)) indice)
   (t (encontrar-peca tabuleiro peca f-pesquisa (1- indice)))
   )
  )

;;Fun��o que recebe uma peca e uma lista e devolve T se a peca estiver na lista e NIL caso contr�rio.
(defun peca-existep (peca lista)
  (cond 
   ((null lista) nil)
   ((equal peca (car lista)) t)
   (t (peca-existep peca (cdr lista)))
   )
  )

;;Fun��o que recebe dois �ndices (linha e coluna) e o tabuleiro e devolve T se a casa estiver vazia e NIL caso contr�rio. O valor de uma casa vazia no Problema do Quatro � o valor 0.
(defun casa-vaziap (linhaTabuleiro colunaTabuleiro tabuleiro)
  (if (or (< linhaTabuleiro 0) (> linhaTabuleiro 3) (> colunaTabuleiro 3) (< colunaTabuleiro 0)) nil (atom (celula linhaTabuleiro colunaTabuleiro tabuleiro)))
  )

;;Fun��o que recebe uma pe�a e uma lista com as pe�as de reserva e devolve uma nova lista sem essa pe�a de reserva.
(defun remover-peca (peca tabuleiroReserva)
  (cond ((null tabuleiroReserva) nil)
        ((equal peca (car tabuleiroReserva)) (remover-peca peca (cdr tabuleiroReserva)))
        (t (cons (car tabuleiroReserva) (remover-peca peca (cdr tabuleiroReserva))))
        )
  )

;;Fun��o que recebe um �ndice, uma pe�a e uma lista que representar� uma linha do tabuleiro e substitui pelo valor pretendido nessa posi��o.
(defun substituir-posicao (indice peca linhaTabuleiro) 
  (cond ((null linhaTabuleiro) nil)
        ((zerop indice) (cons peca (cdr linhaTabuleiro)))
        (t (cons (car linhaTabuleiro) (substituir-posicao (1- indice) peca (cdr linhaTabuleiro))))
        )
  )

;;Fun��o que recebe dois �ndices (linha e coluna), uma pe�a e o tabuleiro. A fun��o dever� retornar o tabuleiro com a c�lula substitu�da pelo valor pretendido. Utilize a fun��o substituir-posicao definida anteriormente.
(defun substituir (linhaTabuleiro colunaTabuleiro peca tabuleiro)
  (cond ((null tabuleiro) nil)
        ((null (casa-vaziap linhaTabuleiro colunaTabuleiro tabuleiro)) nil)
        ((zerop linhaTabuleiro) (cons (substituir-posicao colunaTabuleiro peca (linha linhaTabuleiro tabuleiro)) (cdr tabuleiro)))
        (t (cons (car tabuleiro) (substituir (1- linhaTabuleiro) colunaTabuleiro peca (cdr tabuleiro)))))

  )


;;Fun��o que recebe um no e retorna T caso o no contenha uma solu��o e NIL caso contr�rio. 
(defun no-solucaop(no)
  (let ((tabuleiro (tabuleiro no)))
    (cond 
     ((or (solucaop (diagonal-1 tabuleiro)) 
          (solucaop (diagonal-2 tabuleiro)) 
          (eval (cons 'or (mapcar #'solucaop tabuleiro))) 
          (eval (cons 'or (maplist #'(lambda (tabuleiroParte &aux (tamanho (- (length tabuleiro) (length tabuleiroParte)))) (solucaop (coluna tamanho tabuleiro))) tabuleiro))))
      t)
     (t nil)
     )
    )
  )

;;Fun��o que recebe uma lista e opcionalmente a lista das propriedades e retorna T caso a lista seja uma solu��o e NIL caso contr�rio.
(defun solucaop (lista &optional (props (propriedades)))
  (cond ((null props) nil)
        ((= (length lista) (propriedadep (car props) (alisa lista))) t)
        (t (solucaop lista (cdr props)))
        )
  )

;;Fun��o que retorna todas as propriedades existentes.
(defun propriedades ()
  '(BRANCA PRETA REDONDA QUADRADA ALTA BAIXA OCA CHEIA)
  )

;;Fun��o que recebe uma peca e uma propriedade e retorna a quantidade de vezes que a propriedade se repete na lista.
(defun propriedadep(propriedade lista)
  (cond ( (or (numberp propriedade) (null lista)) 0)
        ((equal propriedade (car lista)) (1+ (propriedadep propriedade (cdr lista))))
        (t (propriedadep propriedade (cdr lista)))
        )
  )

;;Fun��o que recebe uma lista com sub-listas e devolve a mesma sem sub-listas.  
(defun alisa(lista)
  (cond    
   ((null lista) nil)    
   ((atom (car lista)) (cons (car lista) (alisa (cdr lista))))    
   (t (append (alisa (car lista)) (alisa (cdr lista))))  
   ) 
  )

;;================================Operadores e Sucessores==================================

;;Fun��o que recebe dois �ndices (linha e coluna), uma lista que representar� uma pe�a e o tabuleiro com reservas de peca e movimenta a pe�a para a c�lula correspondente, removendo-a da reserva de pe�as. De salientar que o operador deve contemplar a verifica��o da validade do movimento, ou seja, se a casa que se pretende colocar a pe�a se encontra vazia.
(defun operador (linhaTabuleiro colunaTabuleiro peca no)
  (cond ((or (null peca) (null no) (null (casa-vaziap linhaTabuleiro colunaTabuleiro (tabuleiro no)))) nil)
        (t (cria-no (cons (substituir linhaTabuleiro colunaTabuleiro peca (tabuleiro no)) (cons (remover-peca peca (reserva no)) nil)) (1+ (no-profundidade no))))
        )
  )

;;Fun��o que recebe o no inicial e devolve todos os seus sucessores numa lista de n�s.
(defun sucessores (no &optional (profundidade 9999) (pecas (reserva no)) (linhaTabuleiro 0) (colunaTabuleiro 0))
  (remove nil 
          (cond
           ((or (null no) (null pecas) (>= (no-profundidade no) profundidade)) nil)
           ((= linhaTabuleiro 4) (sucessores no profundidade (cdr pecas) 0 0))
           ((= colunaTabuleiro 4) (sucessores no profundidade pecas (1+ linhaTabuleiro) 0))
           (t (cons (operador linhaTabuleiro colunaTabuleiro (car pecas) no) (sucessores no profundidade pecas linhaTabuleiro (1+ colunaTabuleiro))))
           )
          )
  )


;;================================Campeonato==================================

;;Fun��o que retorna uma lista com a coordenadas da jogada e o novo estado.
(defun jogar (estado tempo &optional (profundidade 2))
  (reset-jogada-nos)
  (alfabeta (cria-no estado 0) (/ tempo 1000) profundidade)
  (let ((peca-diferente (encontrar-diferente (car estado) (tabuleiro (first *jogada*)))))
    (list (read-from-string (concatenate 'string (traduzir-valor (encontrar-peca (tabuleiro (first *jogada*)) peca-diferente 'coluna)) (write-to-string (1+ (encontrar-peca (tabuleiro (first *jogada*)) peca-diferente 'linha))))) (no-jogo (first *jogada*)))
  )
)

;;Fun��o que retorna a coordenada da posi��o da coluna da pe�a introduzida.
(defun traduzir-valor (valor)
  (cond 
   ((= valor 0) "A") 
   ((= valor 1) "B")
   ((= valor 2) "C")
   ((= valor 3) "D")
   (t nil)
   )
  )

;;Fun��o que encontra a pe�a que diferencia o tabuleiro antigo do novo. Retorna a pe�a se a encontrar, caso contr�rio retorna nil.
(defun encontrar-diferente (tabuleiro-antigo tabuleiro-novo)
  (cond 
   ((null tabuleiro-antigo) nil)
   ((not (equal (car tabuleiro-antigo) (car tabuleiro-novo))) (encontrar-diferenteLinhas (car tabuleiro-antigo) (car tabuleiro-novo)))
   (t (encontrar-diferente (cdr tabuleiro-antigo) (cdr tabuleiro-novo)))
   )
  )

;;Fun��o que encontra a pe�a que diferencia a linha antiga da nova. Retorna a pe�a se a encontrar, caso contr�rio retorna nil.
(defun encontrar-diferenteLinhas (linha-antiga linha-nova)
  (cond 
   ((null linha-antiga) nil)
   ((not (equal (car linha-antiga) (car linha-nova))) (car linha-nova))
   (t (encontrar-diferenteLinhas (cdr linha-antiga) (cdr linha-nova)))
   )
  )
