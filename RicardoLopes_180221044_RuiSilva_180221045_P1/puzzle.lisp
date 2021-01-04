;;;; puzzle.lisp
;;;; Disciplina de IA - 2020 / 2021
;;;; Problema do Quatro -  1ª parte do projeto de Inteligência Artificial.
;;;; Autores: Ricardo Lopes 180221044, Rui Silva 180221045 


;;===================Seletores================

;;Função que recebe uma lista que contém um tabuleiro com reservas de peça e devolve o tabuleiro
(defun tabuleiro (no)
  (caar no)
)

;;Função que recebe uma lista que contém um tabuleiro com reservas de peça e devolve a reserva de peças
(defun reserva (no)
  (cadar no)
)

;;Função que recebe um índice e o tabuleiro e retorna uma lista que representa essa linha do tabuleiro.
(defun linha (indice tabuleiro)
  (cond ((or (< indice 0) (null tabuleiro)) nil)
        ((zerop indice) (car tabuleiro))
        (t (linha (1- indice) (cdr tabuleiro)))
  )
)

;;Função que recebe um índice e o tabuleiro e retorna uma lista que representa essa coluna do tabuleiro.
(defun coluna (indice tabuleiro)
  (cond ((or (< indice 0) (null tabuleiro)) nil)
  (t (maplist #'(lambda (linhaTabuleiro &aux (cabeca (linha indice (car linhaTabuleiro)))) cabeca) tabuleiro))
  )
)

;;Função que recebe dois índices (linha e coluna) e o tabuleiro e retorna o valor presente nessa célula do tabuleiro.
(defun celula (linhaTabuleiro colunaTabuleiro tabuleiro)
  (linha linhaTabuleiro (coluna colunaTabuleiro tabuleiro))
)

;;Função que recebe um tabuleiro e retorna uma lista que representa uma diagonal desse tabuleiro. Considere a diagonal-1 como a diagonal a começar pela célula na 1ª linha e 1ª coluna.
(defun diagonal-1 (tabuleiro) 
  (maplist #'(lambda (tabuleiroParte &aux (tamanho (- (length tabuleiro) (length tabuleiroParte)))) (celula tamanho tamanho tabuleiro)) tabuleiro)
)

;;Função que recebe um tabuleiro e retorna uma lista que representa uma diagonal desse tabuleiro. Considere a diagonal-2 como a diagonal a começar pela célula na última linha e 1ª coluna.
(defun diagonal-2 (tabuleiro) 
  (maplist #'(lambda (tabuleiroParte &aux (tamanho (- (length tabuleiro) (length tabuleiroParte)))) (celula (1- (length tabuleiroParte)) tamanho tabuleiro)) tabuleiro)
)

;;Função quer recebe um nó e retorna o jogo (tabuleiro e as reservas).
(defun no-jogo (no)
  (car no)
)

;;Função que recebe um nó e retorna a profundidade do nó.
(defun no-profundidade (no)
  (cadr no)
)

;;Função que recebe um nó e retorna o pai do nó.
(defun no-pai (no)
  (caddr no)
)

;;Função que recebe um nó e retorna a heuristica do nó.
(defun no-heuristica (no)
  (cadddr no)
)
;;=================Construtor=====================
;;Função que recebe um jogo (tabuleiro e reservas) e devolve um nó que é uma lista do jogo, da profundidade e do pai do nó inicial.
(defun cria-no (jogo &optional (g 0) (pai nil) (heuristica (heuristica (car jogo))))
  (list jogo g pai heuristica)
)

;;===============Cálculo da heutística para o construtor==============
;;Função que recebe um tabuleiro e devolve a heuristica (h(x) = 4 - (calcular-max)) consoante o número de peças já alinhadas.  
(defun heuristica (tabuleiro)
  (cond 
   ((null tabuleiro) nil)
   (t (apply 'min (alisa (mapcar #'(lambda (linha) (mapcar #'(lambda (peca) (- 4 (calcular-max tabuleiro peca))) linha)) tabuleiro))))
   )
)

;;Função que recebe um tabuleiro e uma peça e devolve o número máximo com características comuns já alinhadas na vertical, horizontal ou diagonal.
(defun calcular-max (tabuleiro peca &aux (colunaPeca (encontrar-peca tabuleiro peca 'coluna)) (linhaPeca (encontrar-peca tabuleiro peca 'linha)))
  (cond ((or (null colunaPeca) (null linhaPeca)) nil)
        ((atom peca) 0)
        (t
         (max (propriedade-comum peca (coluna colunaPeca tabuleiro)) (propriedade-comum peca (linha linhaPeca tabuleiro))
              (cond                                                                               
               ((= colunaPeca linhaPeca) (propriedade-comum peca (diagonal-1 tabuleiro)))
               ((= (+ colunaPeca linhaPeca) (length tabuleiro)) (propriedade-comum peca (diagonal-2 tabuleiro)))
               (t 0)
               )
              ) 
         )
        )
)

;;Função que recebe uma peça e uma lista e devolve o número máximo de propriedades em comum de uma peça com outras da lista.
(defun propriedade-comum (peca lista &optional (x 0))
  (cond 
       ((null peca) x)
       (t (propriedade-comum (cdr peca) lista (max x (propriedadep (car peca) (alisa lista)))))
   )
)

;;Função que recebe um tabuleiro, uma peca, uma função de pesquisa (f-pesquisa) e opcionalmente um indice e devolve o indice onde a peca se encontra e NIL caso a peca não exista. 
(defun encontrar-peca (tabuleiro peca f-pesquisa &optional (indice (1- (length tabuleiro))))
  (cond
   ((< indice 0) nil)
   ((peca-existep peca (funcall f-pesquisa indice tabuleiro)) indice)
   (t (encontrar-peca tabuleiro peca f-pesquisa (1- indice)))
   )
)

;;Função que recebe uma peca e uma lista e devolve T se a peca estiver na lista e NIL caso contrário.
(defun peca-existep (peca lista)
  (cond 
       ((null lista) nil)
       ((equal peca (car lista)) t)
       (t (peca-existep peca (cdr lista)))
       )
)
;;=================Funções auxiliares para cálculo dos sucessores e verificação da solução==================

;;Função que recebe dois índices (linha e coluna) e o tabuleiro e devolve T se a casa estiver vazia e NIL caso contrário. O valor de uma casa vazia no Problema do Quatro é o valor 0.
(defun casa-vaziap (linhaTabuleiro colunaTabuleiro tabuleiro)
  (if (or (< linhaTabuleiro 0) (< colunaTabuleiro 0)) nil (atom (celula linhaTabuleiro colunaTabuleiro tabuleiro)))
)

;;Função que recebe uma peça e uma lista com as peças de reserva e devolve uma nova lista sem essa peça de reserva.
(defun remover-peca (peca tabuleiroReserva)
  (cond ((null tabuleiroReserva) nil)
        ((equal peca (car tabuleiroReserva)) (remover-peca peca (cdr tabuleiroReserva)))
        (t (cons (car tabuleiroReserva) (remover-peca peca (cdr tabuleiroReserva))))
   )
)

;;Função que recebe um índice, uma peça e uma lista que representará uma linha do tabuleiro e substitui pelo valor pretendido nessa posição.
(defun substituir-posicao (indice peca linhaTabuleiro) 
  (cond ((null linhaTabuleiro) nil)
        ((zerop indice) (cons peca (cdr linhaTabuleiro)))
        (t (cons (car linhaTabuleiro) (substituir-posicao (1- indice) peca (cdr linhaTabuleiro))))
  )
)

;;Função que recebe dois índices (linha e coluna), uma peça e o tabuleiro. A função deverá retornar o tabuleiro com a célula substituída pelo valor pretendido. Utilize a função substituir-posicao definida anteriormente.
(defun substituir (linhaTabuleiro colunaTabuleiro peca tabuleiro)
  (cond ((null tabuleiro) nil)
        ((zerop linhaTabuleiro) (cons (substituir-posicao colunaTabuleiro peca (linha linhaTabuleiro tabuleiro)) (cdr tabuleiro)))
        (t (cons (car tabuleiro) (substituir (1- linhaTabuleiro) colunaTabuleiro peca (cdr tabuleiro)))))

)

;;Função que recebe um no e retorna T caso o no contenha uma solução e NIL caso contrário. 
(defun no-solucaop(no)
  (let ((tabuleiro (tabuleiro no)))
    (cond 
       ((or (solucaop (diagonal-1 tabuleiro)) 
            (solucaop (diagonal-2 tabuleiro)) 
            (eval(cons 'or (mapcar #'solucaop tabuleiro))) 
            (eval (cons 'or (maplist #'(lambda (tabuleiroParte &aux (tamanho (- (length tabuleiro) (length tabuleiroParte)))) (solucaop (coluna tamanho tabuleiro))) tabuleiro))))
        t)
       (t nil)
       )
    )
)

;;Função que recebe uma lista e opcionalmente a lista das propriedades e retorna T caso a lista seja uma solução e NIL caso contrário.
(defun solucaop (lista &optional (props (propriedades)))
 (cond ((null props) nil)
       ((= (length lista) (propriedadep (car props) (alisa lista))) t)
       (t (solucaop lista (cdr props)))
       )
)

;;Função que retorna todas as propriedades existentes.
(defun propriedades ()
  '(BRANCA PRETA REDONDA QUADRADA ALTA BAIXA OCA CHEIA)
)

;;Função que recebe uma peca e uma propriedade e retorna a quantidade de vezes que a propriedade se repete na lista.
(defun propriedadep(propriedade lista)
  (cond ((null lista) 0)
        ((equal propriedade (car lista)) (1+ (propriedadep propriedade (cdr lista))))
        (t (propriedadep propriedade (cdr lista)))
)
)

;;Função que recebe uma lista com sub-listas e devolve a mesma sem sub-listas.  
(defun alisa(lista)
   (cond    
       ((null lista) nil)    
       ((atom (car lista)) (cons (car lista) (alisa (cdr lista))))    
       (t (append (alisa (car lista)) (alisa (cdr lista))))  
    ) 
)

;;Função que recebe uma lista de nós e devolve o no que seja uma solução e NIL caso contrário
(defun lista-solucaop (listaJogos f-objetivo)
  (cond ((null listaJogos) nil)
        ((funcall f-objetivo (car listaJogos)) (car listaJogos))
        (t (lista-solucaop (cdr listaJogos) f-objetivo))
        )
)

;;Função que recebe um nó, uma lista e um algoritmo e devolve T se o nó existe dentro da lista e NIL caso contrário.
(defun no-existep(no lista algoritmo)
  (cond 
     ((null lista) nil)
     ((and (equal algoritmo 'dfs) (equal (tabuleiro no) (tabuleiro (car lista))) (< (no-profundidade no) (no-profundidade (car lista))))  t)
     ((and (equal algoritmo 'bfs) (equal (tabuleiro no) (tabuleiro (car lista)))) t)
     ((and (equal algoritmo 'a*) (equal (tabuleiro no) (tabuleiro (car lista))) (< (+ (no-profundidade no) (no-heuristica no)) (+ (no-profundidade (car lista)) (no-heuristica (car lista))))) t)
     (t (no-existep no (cdr lista) algoritmo))
     )
)
;;======================Auxiliares do BFS========================
;;Retorna a junção da lista de nós abertos e o conjunto de nós sucessores de acordo com o algoritmo de procura em largura.
(defun abertos-bfs(nos-abertos sucessores)
  (cond ((null sucessores) nos-abertos)
        ((no-existep (car sucessores) nos-abertos 'bfs) (abertos-bfs nos-abertos (cdr sucessores)))
        (t (abertos-bfs (append nos-abertos (cons (car sucessores) nil)) (cdr sucessores)))
        )
)

;;======================Auxiliares do DFS========================
;;Função que recebe uma lista dos nos-abertos e uma dos sucessores e retorna a junção da lista de nós abertos e o conjunto de nós sucessores de acordo com o algoritmo de procura em profundidade.
(defun abertos-dfs(nos-abertos sucessores)
  (cond ((null sucessores) nos-abertos)
        ((no-existep (car sucessores) nos-abertos 'dfs) (abertos-dfs (troca-no (car sucessores) nos-abertos) (cdr sucessores)))
        (t (abertos-dfs (cons (car sucessores) nos-abertos) (cdr sucessores)))
        )
)

;;======================Auxiliares do Astar=======================
;;Função que recebe um nó e uma lista e devolve a lista com o novo nó no lugar do antigo (utilizado no dfs para recalcular a profundidade de um nó)
(defun troca-no(no lista)
  (cond 
      ((null lista) nil)
      ((equal (tabuleiro no) (tabuleiro (car lista))) (cons no (cdr lista)))
      (t (cons (car lista) (cons (cdr lista) nil)))
   )
)

;;Função que recebe dois nós e devolve t se o custo do no-a for menor que o do no-b e nil caso contrario.
(defun comparar-no(no-a no-b)
  (< (custo no-a) (custo no-b))
)

;;Função que recebe um no e retorna o seu custo (custo = profundidade + heuristica)
(defun custo(no)
  (+ (no-profundidade no) (no-heuristica no))
)


;;Função que recebe uma lista dos nos-abertos e uma dos sucessores e retorna a junção da lista de nós abertos e o conjunto de nós sucessores de acordo com o algoritmo de procura A*.
(defun abertos-a* (nos-abertos sucessores fechados)
  (cond ((null sucessores)  nos-abertos)
        ((no-existep (car sucessores) fechados 'a*) (abertos-a* nos-abertos (cdr sucessores) (troca-no (car sucessores) fechados)))
        ((no-existep (car sucessores) nos-abertos 'a*) (abertos-a* (inserir-ordenado (car sucessores) (remover-no (car sucessores) nos-abertos)) (cdr sucessores) fechados))
        (t (abertos-a* (inserir-ordenado (car sucessores) nos-abertos) (cdr sucessores) fechados))
        )
)


;;Função que recebe um nó e uma lista e devolve uma lista sem o nó escolhido.
(defun remover-no(no lista)
  (cond 
   ((null lista) nil)
   ((equal no (car lista)) (cdr lista))
   (t (cons (car lista) (remover-no no (cdr lista))))
   )
)

;;Função que recebe o NO e a LISTA e devolve uma lista ordenada com o nó.
(defun inserir-ordenado(no lista &optional (indice 0))
  (cond 
   ((null lista) (list no))
   ((equal indice (1- (length lista))) (append lista (cons no nil)))
   ((comparar-no no (nth indice lista)) (insere no indice lista))
   (t (inserir-ordenado no lista (1+ indice)))
)
)

;;Inserir um valor X na posição N de uma lista, mantendo a ordem dos restantes. O primeiro elemento tem o número de ordem 0 (zero).
(defun insere (e n l)
  (labels ((insere-aux (lista p)
             (cond ((null lista) (list e))
                   ((zerop p) (cons e lista))
                   (t (cons (car lista) (insere-aux (cdr lista) (1- p)))))))
    (insere-aux l n)
    )
)

;;======================Auxiliares do Astar=======================
;;Função que recebe uma lista dos nos-abertos e uma dos sucessores e retorna a junção da lista de nós abertos e o conjunto de nós sucessores de acordo com o algoritmo de procura IDA*.
(defun abertos-ida* (nos-abertos sucessores fechados limiar &optional (first 0))
  (cond ((null sucessores)  nos-abertos)
        ((and (< first 1) (analisar-limiar sucessores limiar)) nil)
        ((no-existep (car sucessores) fechados 'a*) (abertos-ida* nos-abertos (cdr sucessores) (troca-no (car sucessores) fechados) limiar (1+ first)))
        ((no-existep (car sucessores) nos-abertos 'a*) (abertos-ida* (inserir-ordenado (car sucessores) (remover-no (car sucessores) nos-abertos)) (cdr sucessores) fechados limiar (1+ first)))
        (t (abertos-ida* (inserir-ordenado (car sucessores) nos-abertos) (cdr sucessores) fechados limiar (1+ first)))
        )
)

;;Função que verifica se todas as peça da lista têm um custo maior que o limiar.
(defun analisar-limiar (lista limiar)
  (eval (cons 'and (mapcar #'(lambda(peca) (if (> (custo peca) limiar) T NIL)) lista)))
)


;;====================Auxiliares avaliação eficiência======================
;;Função do método de bissecção (B + B^2 + ... + B^L=T)
(defun f-polinomial (B L valor-T)
  (cond
   ((= 1 L) (- B valor-T))
   (T (+ (expt B L) (f-polinomial B (- L 1) valor-T)))
  )
)

;;Função que devolve o factor de ramificacao, executando o método da bissecção
(defun ramificacao (no valor-T &optional (valor-L (no-profundidade no)) (erro 0.1) (bmin 1) (bmax 10e11))
  (let ((bmedio (/ (+ bmin bmax) 2)))
    (cond 
     ((< (- bmax bmin) erro) (/ (+ bmax bmin) 2))
     ((< (f-polinomial bmedio valor-L valor-T) 0) (ramificacao no valor-T valor-L erro bmedio bmax))
     (t (ramificacao no valor-T valor-L erro bmin bmedio))
     )
    )
)

;;================================Operadores e Sucessores==================================

;;Função que recebe dois índices (linha e coluna), uma lista que representará uma peça e o tabuleiro com reservas de peca e movimenta a peça para a célula correspondente, removendo-a da reserva de peças. De salientar que o operador deve contemplar a verificação da validade do movimento, ou seja, se a casa que se pretende colocar a peça se encontra vazia.
(defun operador (linhaTabuleiro colunaTabuleiro peca no)
    (cond ((or (null peca) (null no) (null (casa-vaziap linhaTabuleiro colunaTabuleiro (tabuleiro no)))) nil)
        (t (cria-no (cons (substituir linhaTabuleiro colunaTabuleiro peca (tabuleiro no)) (cons (remover-peca peca (reserva no)) nil)) (1+ (no-profundidade no)) no))
    )
)

;;Função que recebe o no inicial e devolve todos os seus sucessores numa lista de nós.
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






