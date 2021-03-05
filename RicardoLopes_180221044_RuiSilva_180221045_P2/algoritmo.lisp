(in-package p180221044-180221045)

;;;; algoritmo.lisp
;;;; Disciplina de IA - 2020 / 2021
;;;; Problema do Quatro -  2� parte do projeto de Intelig�ncia Artificial.
;;;; Autores: Ricardo Lopes 180221044, Rui Silva 180221045 

;;Fun��o que retorna o valor da melhor jogada conforme o tabuleiro atual e a pontua��o desta jogada. Guarda o tabuleiro desta jogada.
(defun alfabeta(no tempo-definido &optional (d 9999) (alfa *menosinfinito*) (beta *maisinfinito*) (jogador 1) (tempo-inicial (get-universal-time)) (tempo-comeco (get-internal-run-time)))
  (update-analisados tempo-comeco) 
  (cond 
   ((> (- (get-universal-time) tempo-inicial) tempo-definido) nil)
   ((or (= (no-profundidade no) d) (no-solucaop no)) (update-jogada no (funcao-avaliacao (tabuleiro no))))
   (t (cond
       ((= jogador 1) (alfabeta-max (sucessores no) tempo-definido alfa beta d tempo-inicial tempo-comeco))   
       (t  (update-jogada no (alfabeta-min (sucessores no) tempo-definido alfa beta d tempo-inicial tempo-comeco)))
       )
      )
   )
  ) 

;;Fun��o que troca a jogada atual e a sua avalia��o para a nova melhor jogada.
(defun update-jogada (no valor)
  (cond 
   ((null valor) (reset-jogada-nos))
   ;;<= n�o resultaria porque contemplaria a possibilidade da jogada ficar com n�s cortados.
   ((and (< (second *jogada*) valor) (= (no-profundidade no) 1)) (setf *jogada* (list no valor)))   
   )
  valor
  )

;;Fun��o que adiciona um n� cortado � lista de n�s cortados.
(defun update-cortados(valor)
  (setf *lista-nos* (list (car *lista-nos*) (1+ (cadr *lista-nos*)) (caddr *lista-nos*)))
  valor
  )

;;Fun��o que adiciona um n� analisado � lista de n�s analisados. 
(defun update-analisados(tempo)
 (setf *lista-nos* (list (1+ (car *lista-nos*)) (cadr *lista-nos*) (- (get-internal-run-time) tempo)))
)

;;Fun��o que calcula recursivamente o m�ximo entre os sucessores dentro do tempo limite definido.
(defun alfabeta-max(sucessores tempo-definido  alfa beta d tempo-inicial tempo-comeco)
  (cond 
   ((null sucessores) alfa)
   (t
    (let ((tempo-excedido (alfabeta (car sucessores) tempo-definido d alfa beta -1 tempo-inicial tempo-comeco))) (cond ((null tempo-excedido) nil) (t
    (let ((maximo (max alfa tempo-excedido)))
      (cond
       ((>= maximo beta)  (update-cortados beta));;contar os cortes
      ((and (> maximo (second *jogada*)) (= d 1)) (update-jogada (car sucessores) (alfabeta-max (cdr sucessores) tempo-definido maximo beta d tempo-inicial tempo-comeco)));;para 1 jogada apenas
       (t (alfabeta-max (cdr sucessores) tempo-definido maximo beta d tempo-inicial tempo-comeco))  
       ))
      )
   )
  )))
)

;;Fun��o que calcula recursivamente o m�nimo entre os sucessores dentro do tempo limite definido.;;Fun��o
(defun alfabeta-min(sucessores tempo-definido alfa beta d tempo-inicial tempo-comeco)
  (cond 
   ((null sucessores) beta)
   (t
    (let ((tempo-excedido (alfabeta (car sucessores) tempo-definido d alfa beta 1 tempo-inicial tempo-comeco))) (cond ((null tempo-excedido) nil) (t
    (let ((minimo (min beta tempo-excedido)))
      (cond
       ((<= minimo alfa) (update-cortados alfa))
       (t  (alfabeta-min (cdr sucessores) tempo-definido alfa minimo d tempo-inicial tempo-comeco))  
       )
      )))))
   )
  )

