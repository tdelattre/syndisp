  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [departures departure]
breed [tortoises tortoise]
breed [ndepartures departure]
  
tortoises-own [    
  autonomy   
  departure-patch-name
  energy   
  reluctance
  sinuosity-in
  sinuosity-out  
  did-out
  angle
  most-close-target
  last-patch-name  
  perceptual-range
  perceptual-field        
  status
  immigrant 
  Age
  OffspringSize
  Fitness
  FitnessAbs
]
  

patches-own [
  name
  patch-type
  
]

departures-own [
  distance-closest
  new?
  ]
ndepartures-own [distance-closest]


globals [
  XDeparturePoints
  YDeparturePoints
  UDXcor
  UDYcor
  DistMinPatch
  DistMeanPatch
  MeanNearestNB
  
  MeanFitnessAtDeath_D
  MeanAgeAtDeath_D
  MeanOffspringAtDeath_D
  TotalFitnessAtDeath_D
  TotalAgeAtDeath_D
  TotalOffspringAtDeath_D
  MeanFitnessAtDeath_R
  MeanAgeAtDeath_R
  MeanOffspringAtDeath_R
  TotalFitnessAtDeath_R
  TotalAgeAtDeath_R
  TotalOffspringAtDeath_R
  ListSize_D
  ListSize_R
  MaxFitnessAbs
  FileMap
  DiffFitnessLiss
  DiffFitnessList
  
  shannon
  even
]  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-landscape 

  clear-all
  ask patches [ 
    set pcolor white
    set patch-type "matrix"
  ]
   
  create-departures number-patches [

  set color red 
  set new? FALSE 
  setxy random-xcor random-ycor
    
  ]
  
  ;if (check-overfit = TRUE)  [
    ;ask departures [
      ;set distance-closest distance (min-one-of (departures) [distance self])
      
      ;while [distance-closest <= patch--size * 2] [ 
     ;   setxy random-xcor random-ycor 
    ;    set distance-closest distance (min-one-of (departures) [distance self]) 
   ;     ]   
  ;    ]
 ;   ] 

if (check-overfit = TRUE)  [
  ask departures [ create-links-with other departures ]
  while  [ min [link-length] of links < (( patch--size * 2) + MinimalDist) ] [layout-spring departures links 0.01  (patch--size * 2) REPULSION ] 
  ;while  [ min [link-length] of links <= patch--size ] [ layout-spring departures links 0 (patch--size * 2) REPULSION ] 
  ;repeat 100 [ layout-spring departures links 0 (patch--size * 2) REPULSION ] ; 
  if ShowLinks? = False [ ask links [  hide-link ] ]
   
]  
  
  ;set pcolor red
  ask departures[ 
    let pname who + 1
    ask patches in-radius patch--size
      [ set pcolor green
        set name pname
        set patch-type "habitat" 
      ] 
  set distance-closest distance (min-one-of (departures) [distance self])
  ;set most-close-target min-one-of (patches in-cone perceptual-range perceptual-field with [pcolor = green]) [ distance myself ]
  set shape "circle"
  ]
  
  
  ;ask departures [die]

  set DistMinPatch (min [link-length] of links  - patch--size * 2)
  set DistMeanPatch (mean [link-length] of links - patch--size * 2)
  set MeanNearestNB ( mean [distance-closest] of departures - patch--size * 2 )
  
  reset-ticks   
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

  
to add-a-patch
  let howmany 1
  if count departures = 0 [set howmany 2]                                                                      ; Tweak to avoid creating a departure without a patch for the first one (when landscape is empty). Probably optimisable.
  
  create-departures howmany [
    set color red
    set new? TRUE
    
    setxy random-xcor random-ycor
    ask departures [ create-links-with other departures ]
    let aap-count 0                                                                                            ; a counter to avoid an eternal loop when there is no solution to create a new patch
    while  [ min [link-length] of links < (( patch--size * 2) + MinimalDist) and aap-count < 2000 ] [ 
      setxy random-xcor random-ycor ask departures [ create-links-with other departures ] 
      set aap-count aap-count + 1                                                                              ; a counter to avoid an eternal loop when there is no solution to create a new patch
      ]
    if aap-count >= 2000 [die]                                                                                 ; without this condition you create a patch in the last wrong place that has been evaluated  
    
    ;ask ndepartures
    ;[ 
      let pname who + 1
    ask patches in-radius patch--size
      [ set pcolor green 
        set name pname
        set patch-type "habitat" 
      ] 
    set distance-closest distance (min-one-of (departures) [distance self])
    
    set shape "circle"
    ;]
  ]
  
  set DistMinPatch (min [link-length] of links - patch--size * 2)
  set DistMeanPatch (mean [link-length] of links - patch--size * 2)
  set MeanNearestNB ( mean [distance-closest] of departures - patch--size * 2 ) 
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
to erase-a-patch

ask one-of departures [
  
  ask patches in-radius patch--size
      [ set pcolor white
        set name 0
        set patch-type "matrix" 
      ]
  die
  ]
ask departures [ 
  create-links-with other departures
  set distance-closest distance (min-one-of (departures) [distance self])
]
set DistMinPatch (min [link-length] of links - patch--size * 2)
set DistMeanPatch (mean [link-length] of links - patch--size * 2)
set MeanNearestNB ( mean [distance-closest] of departures - patch--size * 2 )

end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
to erase-new-patch

ask one-of departures with [ new? = TRUE] [
  
  ask patches in-radius patch--size
      [ set pcolor white
        set name 0
        set patch-type "matrix" 
      ]
  die
  ] 

ask departures [ 
  create-links-with other departures
  set distance-closest distance (min-one-of (departures) [distance self])
]
set DistMinPatch (min [link-length] of links - patch--size * 2)
set DistMeanPatch (mean [link-length] of links - patch--size * 2)
set MeanNearestNB ( mean [distance-closest] of departures - patch--size * 2 )

end
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
to erase-closest-patch

;ask min-one-of departures [distance-closest] [
  
  
;ask patches in-radius patch--size
;[set pcolor pink ]

;] 

  ask min-one-of links [link-length] [ 
  
    ;show-link
    ;set label link-length 
    ;set label-color red
    
    ask one-of both-ends [
      ;set color blue]
      
      
      
      
      ask patches in-radius patch--size
      [ set pcolor white 
        set name 0
        set patch-type "matrix" 
      ]
      die
    ]
  ]
  ask departures [ 
    create-links-with other departures
    set distance-closest distance (min-one-of (departures) [distance self])
  ]
  set DistMinPatch (min [link-length] of links - patch--size * 2)
  set DistMeanPatch (mean [link-length] of links - patch--size * 2)
  set MeanNearestNB ( mean [distance-closest] of departures - patch--size * 2 )
  
end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup-tortoises
  
  set ListSize_R 0
  set ListSize_D 0
  set TotalFitnessAtDeath_R list 0 0
  set TotalOffspringAtDeath_R  list 0 0
  set TotalAgeAtDeath_R   list 0 0
  set TotalFitnessAtDeath_D list 0 0
  set TotalOffspringAtDeath_D  list 0 0
  set TotalAgeAtDeath_D   list 0 0
  set MaxFitnessAbs 0
  set DiffFitnessList   list 0 0
  
  create-tortoises number-tortoises [
    
    move-to one-of departures
    ;set autonomy random-poisson MeanDist
    set departure-patch-name [name] of patch-here
    set pen-mode pen-value
    set angle 0
    ifelse Sinuosity-in-fixed? [set sinuosity-in Sinuosity-in-slider] [set sinuosity-in random 100]
    ifelse Sinuosity-out-fixed? [set sinuosity-out Sinuosity-out-slider] [set sinuosity-out random 100]
    ifelse Reluctance-fixed? [set reluctance Reluctance-slider] [set reluctance random 100]
    ifelse Perception-fixed? 
          [set perceptual-range perceptual-range-slider
           set perceptual-field perceptual-field-slider
          ] 
          [
            if (LimitPerceptualDistance = 50 ) [ set perceptual-range random 50 ]
            if (LimitPerceptualDistance = "Min" ) [ set perceptual-range random DistMinPatch ]
            if (LimitPerceptualDistance = "Mean" ) [ set perceptual-range random DistMeanPatch ]
            if (LimitPerceptualDistance = "MeanNearestNB" ) [ set perceptual-range random MeanNearestNB ]
            ;set perceptual-range random DistMinPatch
            set perceptual-field random 360
          ]
    set did-out false
    set energy 5
    set status one-of [ "disperser" "resident" ]
    if (status = "disperser") [set color blue]
    if (status = "resident") [set color brown]
    set Age 1
    set immigrant FALSE
    set OffspringSize 0
    set Fitness 0
    set FitnessAbs 0
    
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to CaptureMouseXY

  
  if (mouse-down? = TRUE) [ 
    set UDXcor round mouse-xcor
    set UDYcor round mouse-Ycor
        
    create-departures 1 [
      
    set color red 
    set new? TRUE
    
    setxy UDXcor UDYCor 
    ;ask departures [ create-links-with other departures ]
 
           
    ;ask ndepartures
    ;[ 
    let pname who + 1 
    ask patches in-radius patch--size
      [ set pcolor green  
        set name pname
        set patch-type "habitat" 
      ] 
 
    
    set shape "circle"
    ;]
    set distance-closest distance (min-one-of (departures) [distance self]) 
    ]

            


   if (count departures > 3) [
    ask departures [ create-links-with other departures ]
    set DistMinPatch (min (remove 0 ([link-length] of links)) - patch--size * 2)
    set DistMeanPatch (mean (remove 0 ([link-length] of links)) - patch--size * 2)
    set MeanNearestNB ( mean (remove 0 ([distance-closest] of departures)) - patch--size * 2 ) 
  ]     
    
    
    
    
    ]
      

  
   
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to Load-Map
  
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  ask patches [ 
    set pcolor white
    set patch-type "matrix"
  ]
  
  
  file-open UserFileMap ;user-file
  
  repeat file-read [
    
    create-departures 1 [
      
      setxy file-read file-read
      set color red 
      
      
      let pname who + 1 
      ask patches in-radius patch--size
      [ set pcolor green  
        set name pname
        set patch-type "habitat" 
      ] 
      set distance-closest distance (min-one-of (departures) [distance self]) 


    ]
  ]
  
  
  ask departures [ create-links-with other departures ]
  set DistMinPatch (min (remove 0 ([link-length] of links)) - patch--size * 2)
  if (count departures >= 2) [
  set DistMeanPatch (mean (remove 0 ([link-length] of links)) - patch--size * 2)
  ;set MeanNearestNB ( mean (remove 0 ([distance-closest] of departures)) - patch--size * 2 ) 
  ]
  ask links [ hide-link ]
  
  file-close

  
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  
 ; summarize-landscape
;  if (count tortoises with [status = "disperser"] = 0 )  [stop]
;  if (count tortoises with [status = "resident"] = 0)   [stop]
 
  read-patch-name 
  move-tortoises
  perceive-at-distance
  check-death
  reproduce
  eat-grass
  regrow-grass
  destroy
  if (count tortoises = 0) [stop]
  tick
  do-plots
  erase-pen
  calculate-fitness
  calculate-mean-fitness
  check-maxfitnessabs
  do-stats
  

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;to summarize-landscape
;  set DistMinPatch (min [link-length] of links - patch--size * 2)
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to calculate-fitness
  
  ask tortoises [   
    
    if ( FitnessMeasure = "Multiple") [ set Fitness ( Age * OffspringSize ) ]
    if ( FitnessMeasure = "Divide") [ set Fitness ( (OffspringSize) / (Age + 0.0001) ) * 100 ]
    if ( FitnessMeasure = "Relative") [ 
      
      set FitnessAbs ( Age * OffspringSize )
      set Fitness ( FitnessAbs / (MaxFitnessAbs + 0.0001 ) ) * 100
      
    ]
    
    if ( FitnessMeasure = "Absolute") [ set Fitness  OffspringSize ]
    
    if ( FitnessMeasure = "Relative2") [ 
      
      set FitnessAbs ( OffspringSize )
      set Fitness ( FitnessAbs / (MaxFitnessAbs + 0.0001 ) )
      
    ]
    
    ]
  
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-maxfitnessabs
  set MaxFitnessAbs max [FitnessAbs] of tortoises
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to read-patch-name

  ask tortoises[
    if [patch-type] of patch-here = "habitat" [
      set last-patch-name [name] of patch-here ; stocke le nom du dernier patch quitt�
    ]
    
    if (last-patch-name != departure-patch-name) [ set immigrant TRUE ]
    ;set label-color black
    ;set label last-patch-name
  ]
  
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-tortoises
  ask tortoises [
    
    let ProbaSortie random 100
    let new-patch-name [name] of patch-at-heading-and-distance angle 1
    
 ;;;;;;;;;;;
    if (did-out = false) and (new-patch-name != 0) [  ;on est dans l'habitat, on y reste au pixel suivant
      set heading angle
      forward 1
      if pcolor != green [
      if (status = "disperser") and (immigrant = TRUE)  [set energy energy - DisperserImmigCompetitionCost]
      if (status = "disperser") and (immigrant = FALSE) [set energy energy - DisperserHomeCompetitionCost]
      if (status = "resident")  and (immigrant = TRUE)  [set energy energy - ResidentImmigCompetitionCost]
      if (status = "resident")  and (immigrant = FALSE) [set energy energy - ResidentHomeCompetitionCost]

      ]
      let SeuilAutoCor random 100
      if SeuilAutoCor <= sinuosity-in [  set angle random 360  ]
    ]
 ;;;;;;;;;;;   
    if (did-out = false) and (new-patch-name = 0) and (Probasortie <= reluctance) [  ;on est dans l'habitat, pixel suivant mauvais, on choisit de ne pas sortir
      set angle (angle - random 180)
      if angle < -360 [set angle (angle + 360)] 
    ]
 
 ;;;;;;;;;;;   
    if (did-out = false) and (new-patch-name = 0) and (Probasortie >= reluctance) [  ;on est dans l'habitat, pixel suivant mauvais, on choisit de sortir
      set heading angle
      set did-out true
      forward 1
      if pcolor != green [
        ;set autonomy autonomy - 1
        if (status = "disperser") [set energy energy - DisperserMatrixCost ]
        if (status = "resident")  [set energy energy - ResidentMatrixCost ]
      ]
      let SeuilAutoCor random 100
      if SeuilAutoCor <= sinuosity-in [  set angle random 360  ]  
    ]   
 ;;;;;;;;;;;   
    if (did-out = true) and (new-patch-name = 0) [                                 ; on est dans la matrice, prochain pixel mauvais
      
      ifelse (Perceptual-Range?) and (most-close-target != nobody) and ([name] of most-close-target != last-patch-name ) 

      ;;;;;;----
        [ face most-close-target 
          
          let SeuilAutoCor random 100
          if SeuilAutoCor <= sinuosity-out [ right ((random 180) - 90)  ] ;set angle heading + random 90  ]
          set angle heading
          
          forward 1
          if pcolor != green [
            if (status = "disperser") [set energy energy - DisperserMatrixCost ]
            if (status = "resident")  [set energy energy - ResidentMatrixCost  ]    ]
          
        ] 

      ;;;;;;----
        [ set heading angle 
          forward 1
          if pcolor != green [

            if (status = "disperser") [set energy energy - DisperserMatrixCost ]
            if (status = "resident")  [set energy energy - ResidentMatrixCost]
          ]
          let SeuilAutoCor random 100
          if SeuilAutoCor <= sinuosity-out [  set angle random 360  ] 
          
        ]
      
      
      ;;;;;;---- 
      
    ]
    
 ;;;;;;;;;;;   
    if (did-out = true) and (new-patch-name != 0) [                                ; on est dans la matrice, prochain pixel bon
      set did-out false
      set heading angle
      forward 1
      if pcolor != green [
        ;set autonomy autonomy - 1
        if (status = "disperser") [set energy energy - DisperserMatrixCost ]
        if (status = "resident")  [set energy energy - ResidentMatrixCost  ]
        
      ]
    ]    
    
    
    ;right random 360
    ;forward 1
    ;if pcolor != green [
    ;set autonomy autonomy - 1
    ;set energy energy - 1
    ]
  

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to perceive-at-distance
  if ( Perceptual-Range? ) [
    
    ask tortoises [
      
      if (did-out = true) [ 
      

        ;show min-one-of patches with [pcolor = green and distance myself <= distpp] [ distance myself ] ;; --> affiche dans la fen�tre le patch consid�r� par la tortue
        ;set most-close-target min-one-of patches with [pcolor = green and distance myself <= distpp] [ distance myself ] ; voir aussi la fonction in-radius
        set most-close-target min-one-of (patches in-cone perceptual-range perceptual-field with [patch-type = "habitat"]) [ distance myself ]
        ;set most-close-target one-of (patches in-cone 10 60 with [pcolor = green])
        ;if (most-close-target != nobody) [ask most-close-target [set pcolor blue]]
       
      ]
         if (did-out = false) [ set most-close-target nobody ]
        
    ]
  ]
  
  
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to eat-grass
  ask tortoises [
    
    if pcolor = green [
      set pcolor black
           ;; the value of energy-from-grass slider is added to energy

      if (status = "disperser") and (immigrant = TRUE)  [set energy energy + DisperserImmigGainFromFood ]
      if (status = "disperser") and (immigrant = FALSE) [set energy energy + DisperserHomeGainFromFood ]
      if (status = "resident")  and (immigrant = TRUE)  [set energy energy + ResidentImmigGainFromFood ]
      if (status = "resident")  and (immigrant = FALSE) [set energy energy + ResidentHomeGainFromFood ]
     
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to reproduce
  ask tortoises [
  ;if ([name] of patch-here != departure-patch-name) and ([name] of patch-here != 0) and (energy > reproduction-threshold) [    ;; repro dans un nouveau patch uniquement (dispersion obligatoire pour repro)
   if ([name] of patch-here != 0) and (energy > reproduction-threshold) [
    
     ;if (status = "disperser") [set energy energy - (hatch-energy / Ratio) ]
     ;if (status = "resident")  [set energy energy - (hatch-energy * Ratio) ]

     if (status = "disperser") and (immigrant = FALSE)  [set energy energy - DisperserHomeHatchEnergy]
     if (status = "resident")  and (immigrant = FALSE)  [set energy energy - ResidentHomeHatchEnergy ]
     if (status = "disperser") and (immigrant = TRUE)   [set energy energy - DisperserImmigHatchEnergy]
     if (status = "resident")  and (immigrant = TRUE)   [set energy energy - ResidentImmigHatchEnergy ]
 
    hatch 1 [
      
      
      set Age 0
      set OffspringSize 0
      set Fitness 0
      set FitnessAbs 0
      
      if (status = "disperser") and (immigrant = FALSE)  [set energy DisperserHomeHatchEnergy]
      if (status = "resident")  and (immigrant = FALSE)  [set energy ResidentHomeHatchEnergy ]
      if (status = "disperser") and (immigrant = TRUE)   [set energy DisperserImmigHatchEnergy]
      if (status = "resident")  and (immigrant = TRUE)   [set energy ResidentImmigHatchEnergy ]
      
      set immigrant FALSE
      set departure-patch-name [name] of patch-here
      
      if mutations? [ 
        
        ifelse Reluctance-fixed? [set reluctance Reluctance-slider] [
          let Mute1 (random 1000000 / 10000)  
          if Mute1 <= ReluctanceMutationRate [ set reluctance abs ( reluctance - ( (random 200) - 100) )
            if reluctance > 100 [set reluctance reluctance - (reluctance - 100) ] 
            if reluctance < 0 [set reluctance reluctance + (0 - reluctance) ]
          ]
        ]
        
        
        ifelse Sinuosity-in-fixed? [set sinuosity-in Sinuosity-in-slider] [
          let Mute2 (random 1000000 / 10000) 
          if Mute2 <= S-IN_MutationRate [ set sinuosity-in abs ( sinuosity-in - ( (random 200) - 100) )
            if sinuosity-in > 100  [set sinuosity-in sinuosity-in - (sinuosity-in - 100) ]
            if sinuosity-in < 0 [set sinuosity-in sinuosity-in + (0 - sinuosity-in) ] 
          ] 
        ]
        
        ifelse Sinuosity-out-fixed? [set sinuosity-out Sinuosity-out-slider] [
          let Mute3 (random 1000000 / 10000)  
          if Mute3 <= S-OUT_MutationRate [ set sinuosity-out abs ( sinuosity-out - ( (random 200) - 100) ) 
            if sinuosity-out > 100 [set sinuosity-out sinuosity-out - (sinuosity-out - 100) ]
            if sinuosity-out < 0 [set sinuosity-out sinuosity-out + (0 - sinuosity-out) ]  
          ]
        ]
        
        ifelse Status-fixed? [ ] 
        [let Mute4 (random 1000 / 10) 
          
         if Mute4 <= StatusMutationRate [ set status one-of [ "disperser" "resident" ]
           if (status = "disperser") [set color blue]
           if (status = "resident") [set color brown]     
            ] 
          
          ]
        
        if Perceptual-Range? [
        ifelse Perception-fixed? [
          set perceptual-range perceptual-range-slider
          set perceptual-field perceptual-field-slider ]
        [let Mute5 (random 1000000 / 10000)  
          if Mute5 <= Percept_MutationRate [ 
            
            if (LimitPerceptualDistance = 50 ) [  
              set perceptual-range abs ( perceptual-range - ( (random (50 * 2)) - 50) ) 
              if perceptual-range > 50 [set perceptual-range perceptual-range - (perceptual-range - 50) ]
            ]
            if (LimitPerceptualDistance = "Min" ) [  
              set perceptual-range abs ( perceptual-range - ( (random (DistMinPatch * 2)) - DistMinPatch) ) 
              if perceptual-range > DistMinPatch [set perceptual-range perceptual-range - (perceptual-range - DistMinPatch) ]
            ]
            if (LimitPerceptualDistance = "Mean" ) [  
              set perceptual-range abs ( perceptual-range - ( (random (DistMeanPatch * 2)) - DistMeanPatch) ) 
              if perceptual-range > DistMeanPatch [set perceptual-range perceptual-range - (perceptual-range - DistMeanPatch) ]
            ]
            if (LimitPerceptualDistance = "MeanNearestNB" ) [  
              set perceptual-range abs ( perceptual-range - ( (random (MeanNearestNB * 2)) - MeanNearestNB) ) 
              if perceptual-range > MeanNearestNB [set perceptual-range perceptual-range - (perceptual-range - MeanNearestNB) ]
            ]
            
            ;set perceptual-range abs ( perceptual-range - ( (random (DistMinPatch * 2)) - DistMinPatch) ) 
            ;if perceptual-range > DistMinPatch [set perceptual-range perceptual-range - (perceptual-range - DistMinPatch) ]
            if perceptual-range < 0 [set perceptual-range perceptual-range + (0 - perceptual-range) ] 
            
            set perceptual-field abs ( perceptual-field - ( (random 720) - 360) ) 
            if perceptual-field < 0 [set perceptual-field perceptual-field + (0 - perceptual-field) ] 
            if perceptual-field > 360 [set perceptual-field perceptual-field - (perceptual-field - 360) ]
          ]
            
        ]     ]
        
        ;set color one-of base-colors
        ]
      set pen-mode pen-value
      ]
    set OffspringSize OffspringSize + 1
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to regrow-grass
  ask patches [ ;; 3 out of 100 times, the patch color is set to green
    if (name != 0) and (pcolor = black or pcolor = brown) and (random 100 < regrow-rate) [ set pcolor green ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to destroy
  if meteor?[
    let ProbaMeteor random 100
    if ProbaMeteor <= Frequency [
      let destroyed n-of NumberDestroyed [name] of patches
      set destroyed remove 0 destroyed
      ;show destroyed
      foreach destroyed [
        ask patches with [name = ? ] [set pcolor brown]              ; on supprime la ressource (indirect, et repousse vite)
        ask patches with [name = ? ] [ask tortoises-here [die] ]     ; on supprime les individus
        ]
       
    ]
  ]
end
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

to erase-pen
  ask turtles [
    ifelse ([patch-type] of patch-here = "habitat") [ pen-up ] [ set pen-mode pen-value ]    
    ]
end
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  


to check-death
  
  ask tortoises with [ status = "disperser"] [
     ; if autonomy <= 0 [die]   ; mort en fonction de la distance de dispersion

      set Age Age + 1
      
      
      if energy <= 0 [
        
        set TotalFitnessAtDeath_D lput Fitness TotalFitnessAtDeath_D
        set TotalAgeAtDeath_D lput Age TotalAgeAtDeath_D
        set TotalOffspringAtDeath_D lput OffspringSize TotalOffspringAtDeath_D
        set ListSize_D ListSize_D + 1
        
        die]     ; mort en fonction de l'�nergie disponible

      if (AgeLimit? = True) and (Age >= AgeDeath) [ 
        
        set TotalFitnessAtDeath_D lput Fitness TotalFitnessAtDeath_D
        set TotalAgeAtDeath_D lput Age TotalAgeAtDeath_D
        set TotalOffspringAtDeath_D lput OffspringSize TotalOffspringAtDeath_D
        set ListSize_D ListSize_D + 1
        
        die ]
  ]

  ask tortoises with [ status = "resident"] [
    ; if autonomy <= 0 [die]   ; mort en fonction de la distance de dispersion
    
    set Age Age + 1
    
    
    if energy <= 0 [
      
      set TotalFitnessAtDeath_R lput Fitness TotalFitnessAtDeath_R
      set TotalAgeAtDeath_R lput Age TotalAgeAtDeath_R
      set TotalOffspringAtDeath_R lput OffspringSize TotalOffspringAtDeath_R
      set ListSize_R ListSize_R + 1
      
      die]     ; mort en fonction de l'�nergie disponible
    
    if (AgeLimit? = True) and (Age >= AgeDeath) [ 
      
      set TotalFitnessAtDeath_R lput Fitness TotalFitnessAtDeath_R
      set TotalAgeAtDeath_R lput Age TotalAgeAtDeath_R
      set TotalOffspringAtDeath_R lput OffspringSize TotalOffspringAtDeath_R
      set ListSize_R ListSize_R + 1
      
      die ]
  ]
  
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to calculate-mean-fitness


if (length TotalFitnessAtDeath_D > TimeGap ) [
  let depassement (length TotalFitnessAtDeath_D - TimeGap) 
  repeat depassement [ set TotalFitnessAtDeath_D remove-item 0 TotalFitnessAtDeath_D] 
  ]
if (length TotalAgeAtDeath_D > TimeGap ) [
  let depassement (length TotalAgeAtDeath_D - TimeGap) 
  repeat depassement [ set TotalAgeAtDeath_D remove-item 0 TotalAgeAtDeath_D] 
  ]
if (length TotalOffspringAtDeath_D > TimeGap ) [
  let depassement (length TotalOffspringAtDeath_D - TimeGap) 
  repeat depassement [ set TotalOffspringAtDeath_D remove-item 0 TotalOffspringAtDeath_D] 
  ]
 
if (length TotalFitnessAtDeath_D != 0) [ set MeanFitnessAtDeath_D mean TotalFitnessAtDeath_D ]
if (length TotalAgeAtDeath_D != 0) [ set MeanAgeAtDeath_D mean TotalAgeAtDeath_D ]
if (length TotalOffspringAtDeath_D != 0) [ set MeanOffspringAtDeath_D mean TotalOffspringAtDeath_D ]
  
  
  
  
  
  
  
if (length TotalFitnessAtDeath_R > TimeGap ) [
  let depassement (length TotalFitnessAtDeath_R - TimeGap) 
  repeat depassement [ set TotalFitnessAtDeath_R remove-item 0 TotalFitnessAtDeath_R] 
  ]
if (length TotalAgeAtDeath_R > TimeGap ) [
  let depassement (length TotalAgeAtDeath_R - TimeGap) 
  repeat depassement [ set TotalAgeAtDeath_R remove-item 0 TotalAgeAtDeath_R] 
  ]
if (length TotalOffspringAtDeath_R > TimeGap ) [
  let depassement (length TotalOffspringAtDeath_R - TimeGap) 
  repeat depassement [ set TotalOffspringAtDeath_R remove-item 0 TotalOffspringAtDeath_R] 
  ]


if (length TotalFitnessAtDeath_R != 0) [ set MeanFitnessAtDeath_R mean TotalFitnessAtDeath_R ]
if (length TotalAgeAtDeath_R != 0) [ set MeanAgeAtDeath_R mean TotalAgeAtDeath_R ]
if (length TotalOffspringAtDeath_R != 0) [ set MeanOffspringAtDeath_R mean TotalOffspringAtDeath_R ]

let DF MeanFitnessAtDeath_R - MeanFitnessAtDeath_D 
set DiffFitnessList lput DF DiffFitnessList
if (length DiffFitnessList > 400 ) [
  let depassement (length DiffFitnessList - 400) 
  repeat depassement [ set DiffFitnessList remove-item 0 DiffFitnessList] 
  ]
set DiffFitnessLiss mean DiffFitnessList
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;to-report mean-reluctance
;  set mn-rlc ( mean reluctance of tortoises
;  if (count tortoises = 0) [stop]
;  report pctg-disp
;end

to do-plots
  set-current-plot "Population" ;; which plot we want to use next
  ;set-current-plot-pen "tortoises" ;; which pen we want to use next
  ;plot count tortoises ;; what will be plotted by the current pen
  ;set-current-plot-pen "grass" ;; which pen we want to use next
  ;plot count patches with [pcolor = green] ;; what will be plotted by the current pen
  set-current-plot-pen "dispersers"
  plot count tortoises with [status = "disperser"]
  set-current-plot-pen "residents"
  plot count tortoises with [status = "resident"]
  
  set-current-plot "Reluctance to emigrate"
    set-current-plot-pen "Mean of dispersers"
    ifelse (count tortoises with [status = "disperser"] != 0) [plot mean [reluctance] of tortoises with [status = "disperser"]] [plot 0]
    ;set-current-plot-pen "Min of dispersers"
    ;ifelse (count tortoises with [status = "disperser"] != 0) [plot min [reluctance] of tortoises with [status = "disperser"]] [plot 0]
    ;set-current-plot-pen "Max of dispersers"
    ;ifelse (count tortoises with [status = "disperser"] != 0) [plot max [reluctance] of tortoises with [status = "disperser"]] [plot 0]
      set-current-plot-pen "Mean of residents"
      ifelse (count tortoises with [status = "resident"] != 0) [plot mean [reluctance] of tortoises with [status = "resident"]] [plot 0]
      ;set-current-plot-pen "Min of residents"
      ;ifelse (count tortoises with [status = "resident"] != 0) [plot min [reluctance] of tortoises with [status = "resident"]] [plot 0]
      ;set-current-plot-pen "Max of residents"
      ;ifelse (count tortoises with [status = "resident"] != 0) [plot max [reluctance] of tortoises with [status = "resident"]] [plot 0]
  
  set-current-plot "Sinuosity"
  ;set-current-plot-pen "Sinuosity IN"
  ;plot mean [sinuosity-in] of tortoises
  ;set-current-plot-pen "Sinuosity OUT"
  ;plot mean [sinuosity-out] of tortoises
    set-current-plot-pen "Sinu. IN D"
    ifelse (count tortoises with [status = "disperser"] != 0) [plot mean [sinuosity-in] of tortoises with [status = "disperser"]] [plot 0]
    set-current-plot-pen "Sinu. OUT D"
    ifelse (count tortoises with [status = "disperser"] != 0) [plot mean [sinuosity-out] of tortoises with [status = "disperser"]] [plot 0]
      set-current-plot-pen "Sinu. IN R"
      ifelse (count tortoises with [status = "resident"] != 0) [plot mean [sinuosity-in] of tortoises  with [status = "resident"]] [plot 0]
      set-current-plot-pen "Sinu. OUT R"
      ifelse (count tortoises with [status = "resident"] != 0) [plot mean [sinuosity-out] of tortoises  with [status = "resident"]] [plot 0]
  
  set-current-plot "Perceptual distance"
  set-current-plot-pen "Dispersers"
  ifelse (count tortoises with [status = "disperser"] != 0) [plot mean [perceptual-range] of tortoises with [status = "disperser"] ] [plot 0]
  set-current-plot-pen "Residents"
  ifelse (count tortoises with [status = "resident"] != 0) [plot mean [perceptual-range] of tortoises with [status = "resident"] ] [plot 0]
  
  set-current-plot "Perceptual field"
  set-current-plot-pen "Dispersers"
  ifelse (count tortoises with [status = "disperser"] != 0) [plot mean [perceptual-field] of tortoises with [status = "disperser"] ] [plot 0]
  set-current-plot-pen "Residents"
  ifelse (count tortoises with [status = "resident"] != 0) [plot mean [perceptual-field] of tortoises with [status = "resident"] ] [plot 0]
  
  set-current-plot "Fitness"
  set-current-plot-pen "Dispersers"
  ifelse (count tortoises with [status = "disperser"] != 0) [plot MeanFitnessAtDeath_D ] [plot 0]
  set-current-plot-pen "Residents"
  ifelse (count tortoises with [status = "resident"] != 0) [plot MeanFitnessAtDeath_R ] [plot 0]
  
  set-current-plot "DiffFitness"
  set-current-plot-pen "Fitness R- Fitness D"
  plot ((MeanFitnessAtDeath_R - MeanFitnessAtDeath_D) / 1.1 )
  set-current-plot-pen "Zero Line"
  plot 0
  set-current-plot-pen "Smoothed DiffFitness"
  plot DiffFitnessLiss
    
;  set-current-plot "Dispersal Distance"
;  set-current-plot-pen "Distance"
;  plot mean [autonomy] of tortoises
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to do-stats
  
  let Ndisp count tortoises with [status = "disperser"]
  let Nres count tortoises with [status = "resident"]
  let tot Ndisp + Nres
  let piDisp Ndisp / tot
  let piRes Nres / tot
  ifelse Ndisp > 0 and Nres > 0 [
  set shannon ( - (piDisp * log piDisp 2) + (piRes * log piRes 2) )
  let ShannonMax log 2 2 ;log species numer, base 2
  set even shannon / ShannonMax
  ] [
  set shannon 0
  set even 0
  ]
  
  
  
  
end
@#$#@#$#@
GRAPHICS-WINDOW
440
13
924
518
50
50
4.7
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
925
14
1077
47
NIL
setup-landscape   
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
925
49
1048
82
NIL
setup-tortoises
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
7
103
179
136
number-patches
number-patches
0
20
10
1
1
NIL
HORIZONTAL

SLIDER
181
103
353
136
patch--size
patch--size
0
50
8
1
1
NIL
HORIZONTAL

SLIDER
2269
37
2441
70
number-tortoises
number-tortoises
0
100
1000
1
1
NIL
HORIZONTAL

BUTTON
925
83
988
116
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1587
102
1644
147
Population
count tortoises
17
1
11

SLIDER
2100
704
2277
737
reproduction-threshold
reproduction-threshold
0
100
20
1
1
NIL
HORIZONTAL

PLOT
1068
13
1329
146
Population
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"dispersers" 1.0 0 -13345367 true "" ""
"residents" 1.0 0 -6459832 true "" ""

SLIDER
4
526
143
559
regrow-rate
regrow-rate
0
100
3
1
1
NIL
HORIZONTAL

MONITOR
1394
143
1457
188
S-IN-Disp
mean [sinuosity-in] of tortoises with [status = \"disperser\"]
3
1
11

MONITOR
1332
143
1395
188
S-OUT-Disp
mean[sinuosity-out] of tortoises with [status = \"disperser\"]
3
1
11

MONITOR
1330
354
1385
399
min
min [reluctance] of tortoises with [status = \"disperser\"]
17
1
11

PLOT
1069
297
1330
447
Reluctance to emigrate
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Mean of dispersers" 1.0 0 -10649926 true "" ""
"Max of dispersers" 1.0 0 -13345367 false "" ""
"Mean of residents" 1.0 0 -5207188 true "" ""
"Min of residents" 1.0 0 -2570826 false "" ""
"Max of residents" 1.0 0 -6459832 false "" ""
"Min of Disperser" 1.0 0 -8020277 false "" ""

PLOT
1069
147
1331
297
Sinuosity
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Sinu. IN D" 1.0 0 -10649926 true "" ""
"Sinu. OUT D" 1.0 0 -15390905 true "" ""
"Sinu. IN R" 1.0 0 -3889007 true "" ""
"Sinu. OUT R" 1.0 0 -8431303 true "" ""

MONITOR
1333
297
1463
342
Reluctance (nb of values)
length ( remove-duplicates [reluctance] of tortoises )
17
1
11

SWITCH
2097
140
2213
173
mutations?
mutations?
0
1
-1000

SWITCH
5
486
108
519
meteor?
meteor?
1
1
-1000

SLIDER
108
486
263
519
NumberDestroyed
NumberDestroyed
0
15
1
1
1
NIL
HORIZONTAL

SLIDER
263
486
371
519
Frequency
Frequency
0
100
10
1
1
NIL
HORIZONTAL

CHOOSER
440
519
532
564
pen-value
pen-value
"erase" "up" "down"
0

SLIDER
2795
142
2967
175
Sinuosity-in-slider
Sinuosity-in-slider
0
100
75
1
1
NIL
HORIZONTAL

SLIDER
2821
111
2993
144
Sinuosity-out-slider
Sinuosity-out-slider
0
100
25
1
1
NIL
HORIZONTAL

SLIDER
2793
175
2965
208
Reluctance-slider
Reluctance-slider
0
100
90
1
1
NIL
HORIZONTAL

SWITCH
2564
175
2737
208
Reluctance-fixed?
Reluctance-fixed?
1
1
-1000

SWITCH
2564
142
2737
175
Sinuosity-in-fixed?
Sinuosity-in-fixed?
1
1
-1000

SWITCH
2564
110
2737
143
Sinuosity-out-fixed?
Sinuosity-out-fixed?
1
1
-1000

SWITCH
2564
247
2739
280
Perceptual-range?
Perceptual-range?
0
1
-1000

SLIDER
2923
280
3102
313
perceptual-range-slider
perceptual-range-slider
0
100
5
1
1
NIL
HORIZONTAL

SLIDER
2753
280
2925
313
perceptual-field-slider
perceptual-field-slider
0
360
186
1
1
NIL
HORIZONTAL

SWITCH
2564
280
2753
313
Perception-fixed?
Perception-fixed?
1
1
-1000

PLOT
1069
452
1330
602
Perceptual distance
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Residents" 1.0 0 -8431303 true "" ""
"Dispersers" 1.0 0 -13345367 true "" ""

MONITOR
1264
548
1322
593
Dispersers
mean [perceptual-range] of tortoises with [status = \"disperser\"]
3
1
11

PLOT
1329
452
1589
602
Perceptual field
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Residents" 1.0 0 -8431303 true "" ""
"Dispersers" 1.0 0 -13345367 true "" ""

MONITOR
744
655
924
700
Number of occupied patches
length remove-duplicates [name] of patches with [tortoises-here != nobody]
3
1
11

SLIDER
2097
37
2269
70
number-tortoises
number-tortoises
0
1000
1000
100
1
NIL
HORIZONTAL

BUTTON
9
260
102
294
NIL
add-a-patch
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
7
140
179
173
check-overfit
check-overfit
0
1
-1000

MONITOR
1585
13
1642
58
dispersers
count tortoises with [status = \"disperser\"]
17
1
11

MONITOR
1587
58
1643
103
residents
count tortoises with [status = \"resident\"]
17
1
11

SWITCH
2102
639
2210
672
AgeLimit?
AgeLimit?
1
1
-1000

INPUTBOX
2213
639
2274
699
AgeDeath
200
1
0
Number

MONITOR
1068
718
1134
763
Mean Age
mean [Age] of tortoises
2
1
11

MONITOR
1389
355
1475
400
%D-Immigrants
( (count tortoises with [ immigrant = TRUE  and status = \"disperser\"]) /\n(count tortoises with [ status = \"disperser\"]) ) * 100
2
1
11

SWITCH
2224
141
2353
174
Status-fixed?
Status-fixed?
1
1
-1000

MONITOR
1389
400
1468
445
%RImmigrants
( (count tortoises with [ immigrant = TRUE  and status = \"resident\"]) /\n(count tortoises with [ status = \"resident\"]) ) * 100
2
1
11

MONITOR
1224
399
1311
444
Mean Residents
mean [reluctance] of tortoises with [status = \"resident\"]
3
1
11

MONITOR
1330
400
1387
445
min
min [reluctance] of tortoises with [status = \"resident\"]
17
1
11

MONITOR
1068
665
1160
710
Energy Residents
mean [energy] of tortoises with [status = \"resident\"]
2
1
11

MONITOR
1068
620
1163
665
Energy Dispersers
mean [energy] of tortoises with [status = \"disperser\"]
3
1
11

MONITOR
1332
188
1394
233
S-OUT-Res
mean[sinuosity-out] of tortoises with [status = \"resident\"]
3
1
11

MONITOR
1393
188
1456
233
S-IN-Res
mean [sinuosity-in] of tortoises with [status = \"resident\"]
3
1
11

INPUTBOX
2098
370
2202
430
StatusMutationRate
1.0E-4
1
0
Number

MONITOR
1136
718
1225
763
Mean Age Dis.
mean [Age] of tortoises with [status = \"disperser\"]
3
1
11

MONITOR
1228
718
1328
763
Mean Age Res.
mean [Age] of tortoises with [status = \"resident\"]
3
1
11

BUTTON
926
137
989
170
Kill all
ask tortoises [die]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
926
172
1049
205
Resume Patches
 ask departures[ \n    ask patches in-radius patch--size\n      [ set pcolor green      ]]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1264
503
1322
548
Residents
mean [perceptual-range] of tortoises with [status = \"resident\"]
3
1
11

MONITOR
1519
548
1586
593
Dispersers
mean [perceptual-field] of tortoises with [status = \"disperser\"]
17
1
11

MONITOR
1519
504
1586
549
Residents
mean [perceptual-field] of tortoises with [status = \"resident\"]
17
1
11

INPUTBOX
2097
185
2230
245
ReluctanceMutationRate
1.0E-4
1
0
Number

INPUTBOX
2097
248
2200
308
S-IN_MutationRate
1.0E-4
1
0
Number

INPUTBOX
2200
248
2313
308
S-OUT_MutationRate
1.0E-4
1
0
Number

INPUTBOX
2098
310
2215
370
Percept_MutationRate
1.0E-4
1
0
Number

SLIDER
3162
62
3404
95
ResidentHomeGainFromFood
ResidentHomeGainFromFood
0
30
11
0.1
1
NIL
HORIZONTAL

SLIDER
3162
96
3404
129
ResidentImmigGainFromFood
ResidentImmigGainFromFood
0
30
14
0.1
1
NIL
HORIZONTAL

SLIDER
3162
129
3404
162
DisperserHomeGainFromFood
DisperserHomeGainFromFood
0
30
9
0.1
1
NIL
HORIZONTAL

SLIDER
3162
161
3404
194
DisperserImmigGainFromFood
DisperserImmigGainFromFood
0
30
14
0.1
1
NIL
HORIZONTAL

SLIDER
3163
511
3335
544
DisperserMatrixCost
DisperserMatrixCost
0
10
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
3163
480
3335
513
ResidentMatrixCost
ResidentMatrixCost
0
10
1.4
0.1
1
NIL
HORIZONTAL

SLIDER
3162
202
3404
235
ResidentHomeHatchEnergy
ResidentHomeHatchEnergy
0
30
10
0.1
1
NIL
HORIZONTAL

SLIDER
3162
236
3403
269
DisperserHomeHatchEnergy
DisperserHomeHatchEnergy
0
30
10
0.1
1
NIL
HORIZONTAL

SLIDER
3162
343
3403
376
ResidentHomeCompetitionCost
ResidentHomeCompetitionCost
0
10
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
3162
376
3403
409
DisperserHomeCompetitionCost
DisperserHomeCompetitionCost
0
10
0.7
0.1
1
NIL
HORIZONTAL

MONITOR
1499
355
1575
400
ResidentNote
ResidentHomeGainFromFood  * patch--size\n+ ResidentImmigGainFromFood * patch--size\n- ResidentMatrixCost  * (20 - patch--size)\n+ ResidentImmigHatchEnergy\n+ ResidentHomeHatchEnergy\n- ResidentHomeCompetitionCost * patch--size\n- ResidentImmigCompetitionCost * patch--size
3
1
11

MONITOR
1499
402
1574
447
DisperserNote
DisperserHomeGainFromFood * patch--size\n+ DisperserImmigGainFromFood * patch--size\n- DisperserMatrixCost * (20 - patch--size)\n+ DisperserHomeHatchEnergy\n+ DisperserImmigHatchEnergy\n- DisperserHomeCompetitionCost * patch--size\n- DisperserImmigCompetitionCost * patch--size
17
1
11

SLIDER
3162
410
3403
443
ResidentImmigCompetitionCost
ResidentImmigCompetitionCost
0
10
1.4
0.1
1
NIL
HORIZONTAL

SLIDER
3162
443
3403
476
DisperserImmigCompetitionCost
DisperserImmigCompetitionCost
0
10
1.2
0.1
1
NIL
HORIZONTAL

SLIDER
3162
270
3404
303
ResidentImmigHatchEnergy
ResidentImmigHatchEnergy
0
30
10
0.1
1
NIL
HORIZONTAL

SLIDER
3162
302
3404
335
DisperserImmigHatchEnergy
DisperserImmigHatchEnergy
0
30
10
0.1
1
NIL
HORIZONTAL

MONITOR
1224
353
1311
398
Mean Dispersers
mean [reluctance] of tortoises with [status = \"disperser\"]
3
1
11

BUTTON
104
260
210
294
NIL
erase-a-patch
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
295
131
329
NIL
erase-new-patch
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
2564
55
2737
100
LimitPerceptualDistance
LimitPerceptualDistance
50 "Mean" "Min" "MeanNearestNB"
2

MONITOR
744
563
924
608
Minimal dist. btw patches
DistMinPatch
3
1
11

SWITCH
594
567
722
600
ShowLinks?
ShowLinks?
1
1
-1000

MONITOR
744
609
924
654
Mean dist. btw patches
DistMeanPatch
3
1
11

MONITOR
744
518
924
563
Mean Nrst Neighbour dist
MeanNearestNB
3
1
11

BUTTON
440
567
513
601
Hide Links
ask links [hide-link]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1177
620
1320
665
NIL
MeanFitnessAtDeath_R
17
1
11

MONITOR
1319
620
1475
665
NIL
MeanOffspringAtDeath_R
17
1
11

MONITOR
1474
620
1600
665
NIL
MeanAgeAtDeath_R
17
1
11

MONITOR
1177
665
1320
710
NIL
MeanFitnessAtDeath_D
17
1
11

MONITOR
1319
665
1475
710
NIL
MeanOffspringAtDeath_D
17
1
11

MONITOR
1474
665
1600
710
NIL
MeanAgeAtDeath_D
17
1
11

PLOT
1329
13
1589
144
Fitness
NIL
NIL
0.0
5.0
0.0
1.0
true
true
"" ""
PENS
"Dispersers" 1.0 0 -13345367 true "" ""
"Residents" 1.0 0 -6459832 true "" ""

SLIDER
536
520
708
553
TimeGap
TimeGap
0
2000
2000
100
1
NIL
HORIZONTAL

CHOOSER
2097
435
2235
480
FitnessMeasure
FitnessMeasure
"Multiple" "Divide" "Relative" "Relative2" "Absolute"
4

BUTTON
127
373
254
406
Draw a patch
CaptureMouseXY
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
7
373
125
406
Erase landscape
  clear-all\n  ask patches [ \n    set pcolor white\n    set patch-type \"matrix\"\n  ]\n  \n  reset-ticks
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
512
567
594
601
Show Links
ask links [\nshow-link\n;set label link-length \n;set label-color 0\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
8
591
95
636
Save-XY
file-open user-new-file\nfile-write count departures\nask departures [   file-write xcor file-write ycor ]\n;ask departures [   file-write ycor ]\nfile-close\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
95
591
209
636
Load a Map
Load-Map
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
255
373
380
406
NIL
print mouse-xcor
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
745
701
924
746
Number of Patches
count departures
17
1
11

BUTTON
132
295
273
329
NIL
erase-closest-patch
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
8
639
183
684
UserFileMap
UserFileMap
"cartes//p20s8md4" "cartes//p19s8md4" "cartes//p18s8md4" "cartes//p17s8md4" "cartes//p16s8md4" "cartes//p15s8md4" "cartes//p14s8md4" "cartes//p13s8md4" "cartes//p12s8md4" "cartes//p11s8md4" "cartes//p10s8md4" "cartes//p9s8md4" "cartes//p8s8md4" "cartes//p7s8md4" "cartes//p6s8md4" "cartes//p5s8md4" "cartes//p4s8md4" "cartes//p3s8md4" "cartes//p2s8md4" "cartes//essai" "essai2" "cartes//p20s8md4_2" "cartes//p19s8md4_2" "cartes//p18s8md4_2" "cartes//p17s8md4_2" "cartes//p16s8md4_2" "cartes//p15s8md4_2" "cartes//p14s8md4_2" "cartes//p13s8md4_2" "cartes//p12s8md4_2" "cartes//p11s8md4_2" "cartes//p10s8md4_2" "cartes//p9s8md4_2" "cartes//p8s8md4_2" "cartes//p7s8md4_2" "cartes//p6s8md4_2" "cartes//p5s8md4_2" "cartes//p4s8md4_2" "cartes//p3s8md4_2" "cartes//p2s8md4_2" "cartes//p20s8md4_3" "cartes//p19s8md4_3" "cartes//p18s8md4_3" "cartes//p17s8md4_3" "cartes//p16s8md4_3" "cartes//p15s8md4_3" "cartes//p14s8md4_3" "cartes//p13s8md4_3" "cartes//p12s8md4_3" "cartes//p11s8md4_3" "cartes//p10s8md4_3" "cartes//p9s8md4_3" "cartes//p8s8md4_3" "cartes//p7s8md4_3" "cartes//p6s8md4_3" "cartes//p5s8md4_3" "cartes//p4s8md4_3" "cartes//p3s8md4_3" "cartes//p2s8md4_3" "cartes//p20s8md4_4" "cartes//p19s8md4_4" "cartes//p18s8md4_4" "cartes//p17s8md4_4" "cartes//p16s8md4_4" "cartes//p15s8md4_4" "cartes//p14s8md4_4" "cartes//p13s8md4_4" "cartes//p12s8md4_4" "cartes//p11s8md4_4" "cartes//p10s8md4_4" "cartes//p9s8md4_4" "cartes//p8s8md4_4" "cartes//p7s8md4_4" "cartes//p6s8md4_4" "cartes//p5s8md4_4" "cartes//p4s8md4_4" "cartes//p3s8md4_4" "cartes//p2s8md4_4" "cartes//p20s8md4_5" "cartes//p19s8md4_5" "cartes//p18s8md4_5" "cartes//p17s8md4_5" "cartes//p16s8md4_5" "cartes//p15s8md4_5" "cartes//p14s8md4_5" "cartes//p13s8md4_5" "cartes//p12s8md4_5" "cartes//p11s8md4_5" "cartes//p10s8md4_5" "cartes//p9s8md4_5" "cartes//p8s8md4_5" "cartes//p7s8md4_5" "cartes//p6s8md4_5" "cartes//p5s8md4_5" "cartes//p4s8md4_5" "cartes//p3s8md4_5" "cartes//p2s8md4_5"
52

MONITOR
1455
263
1552
308
%Diff_Fitness_RD
((MeanFitnessAtDeath_R - MeanFitnessAtDeath_D) / 1.1 ) * 100
2
1
11

MONITOR
1553
263
1631
308
Diff_FitnessRD
((MeanFitnessAtDeath_R - MeanFitnessAtDeath_D) / 1.1 )
2
1
11

PLOT
1458
144
1781
264
DiffFitness
NIL
NIL
0.0
10.0
-0.01
0.01
true
true
"" ""
PENS
"Fitness R- Fitness D" 1.0 0 -6459832 true "" ""
"Zero Line" 1.0 0 -955883 true "" ""
"Smoothed DiffFitness" 1.0 0 -13345367 true "" ""

MONITOR
1539
308
1631
353
NIL
DiffFitnessLiss
4
1
11

TEXTBOX
8
12
320
63
[--------- Setup Landscape ---------]\n[-----------------------------------------]
18
0.0
1

TEXTBOX
11
241
322
271
//-- Tuning Landscape After Setup (automatic)
12
0.0
1

TEXTBOX
9
80
203
98
//-- Landscape structure
12
0.0
1

TEXTBOX
2103
17
2314
35
//-- Population basic parameters --\\\\
12
0.0
1

TEXTBOX
10
464
387
494
//-- Landscape dynamics
12
0.0
1

TEXTBOX
10
351
318
381
//-- Tuning Landscape After Setup (manual)
12
0.0
1

TEXTBOX
10
575
206
593
//-- Save & Load Landscapes --\\\\
12
0.0
1

TEXTBOX
1960
17
2074
940
>> Other parameters\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n>>\n
10
0.0
1

TEXTBOX
2100
117
2399
147
//-- Mutations, evolution, reproduction
12
0.0
1

TEXTBOX
2566
30
2807
60
//-- Movement parameters
12
0.0
1

TEXTBOX
2103
614
2343
644
//-- Population & Life History traits
12
0.0
1

SLIDER
181
140
353
173
repulsion
repulsion
0
1000
704
1
1
NIL
HORIZONTAL

SLIDER
181
175
353
208
MinimalDist
MinimalDist
0
100
1
1
1
NIL
HORIZONTAL

TEXTBOX
3160
29
3464
59
Costs and advantages for each team
12
0.0
1

MONITOR
745
747
924
792
Habitat Fragmentation (%)
100 - ((count patches with [patch-type = \"habitat\"] / count patches with [patch-type = \"matrix\"]) * 100)
17
1
11

MONITOR
3165
572
3322
617
DisperserImmigTotalScore
DisperserImmigGainFromFood - DisperserImmigCompetitionCost - DisperserMatrixCost
17
1
11

MONITOR
442
645
593
690
NIL
shannon
17
1
11

MONITOR
440
693
592
738
NIL
even
17
1
11

MONITOR
3166
622
3321
667
ResidentImmigTotalScore
ResidentImmigGainFromFood - ResidentImmigCompetitionCost - ResidentMatrixCost
2
1
11

@#$#@#$#@
# Gestion de routine du modèle
## DEBUGGAGE A FAIRE

	// t


## Changelog : 

	// V8 dans reproduce, "set immigrant FALSE" déplacé après la transmission d'énergie qui est conditionnelle à "immigrant" (était placé avant) --> nécessite de refaire tourner les simus, la fitness doit être impactée
	// V8 "set departure-patch-name [name] of patch-here" ajouté à la fonction reproduce --> nécessite de refaire tourner les simus, la fitness doit être impactée 
	// V9 : impossible de maintenir les disperseurs dans la population : changement de set de paramètre pour tenter d'y remédier (nouvelle version pour conserver le paramétrage de V8).
	// V9 : ajout du calcul de l'indice d'équitabilité + shannon pour optimisation

# WHAT IS IT?

Below there we propose a summarized description of the Individual-Based Model created and used in this work, following the standard ODD protocol (“Overview, Design concepts, Details”) proposed by [1,2]. This protocol is today’s best and probably only way to avoid the most common criticism against IBM, namely being irreproducible due to lacks of completeness, understandability and standardization. The model was created with NetLogo [3] and analyzed in R [4]. The corresponding author will provide the source code of the model under request.
# Model overview :

## i. Purpose

The purpose of this model is to improve our understanding about how phenotypical traits associated with dispersal may evolve in a consistent suite (i.e., dispersal syndromes sensu Ronce & Clobert (2012) even when they are not intrinsically linked. We apply this general question to the evolution of behavioural parameters associated with each of the three different phases of dispersal, although we want our model to be sufficiently general to apply to other set of phenotypical traits. We chose to work with non-specific (i.e. virtual species) agents in order to draw as general conclusions as possible.
## ii. Entities, state variables and scales
The model simulates a patchy landscape in which a number of individuals move and reproduce freely. We intend model runs to simulate periods of several hundreds of generations, and model space to simulate landscapes large enough to house a typical metapopulation. However, because the model is not species-specific the grid cells and the time steps do not represent real units of space and time: their variations should only be considered relatively. 
We used a continuous space model (i.e. a torus) in order to avoid undesirable side effects. The landscape is a 100x100 grid of cells, each of which belonging to one of two types of ground cover, either hostile matrix or good habitat. Each habitat cell belongs to only one “patch”, defined as a circular group of contiguous habitat cells with a radius of 8 cells. Habitat cells are also defined by their resource state: they can be either full of resources or empty when an individual ate it. 
The individuals are characterized by a number of state variables. Basic state variables include their identity number, their position (grid cell coordinates), and their age (number of time steps). Individuals are also characterized by their “energy reserves” (abstract units, hereafter “U”) that they can use to move and reproduce. Each individual belongs either to the “Disperser” or “Resident” phenotype category, which is defined at birth and can’t change during its life. Variables related to dispersal behaviour are also defined at birth (see iii for details on the process) and include the emigration propensity (0-100%), the sinuosity of paths (0-100%) and the perceptual range, (i.e. the maximal distance at which an individual may detect a habitat patch and decide to make tracks). Perceptual range is arbitrarily constrained to the minimal distance between patches in the landscape. This to avoid unrealistic process to appear, where individuals evolve a huge perceptual distance and are able to immediately zero in on the nearest patch without doing any errors).
## iii. Process overview and scheduling
The time is discreet. The model first creates and distributes individuals into the landscape (see v., Initialisation). Then, at each time step the main procedures happen in the order specified in Figure 1. The order in which the individuals follow these procedures is randomly drawn at each step. 
Some procedures of data compilation are followed by the “observer”, i.e. a controller object, different from the individuals, that performs actions applying to the whole virtual world. 
Each simulation was run for 5000 time steps, which we found enough to allow a stabilisation of the population and individual parameters of interest (in every set of parameters). 

Figure1. Outline of the procedures of the model, during a time interval. Each process is more extensively detailed in the “Submodels” section (vi.)

## iv. Design concepts
### 1. Basic and ecological principles
The model’s design treats dispersal as a context- and condition-dependent ecological process (Clobert et al. 2008, 2009) in which both environmental (landscape and population) and individual attributes interfere to obtain the final dispersal pattern. Conceptually, dispersal is divided in three phases (emigration, transfer, immigration) (Baguette & Van Dyck 2007, Clobert et al. 2009) each of which is addressed separately in the model with different individual parameters (respectively, emigration propensity, path sinuosity and perceptual range).
Scramble competition for resources and the carrying capacity of habitat patches are both addressed in the model by attributing to each cell a fixed and uniform amount of energy that can be used by individuals here and is therefore unavailable for the others. These resources re-grow after a given amount of time, which is ultimately the parameter that drives the global carrying capacity and the intensity of competition in the system.
Adaptive dynamics are simulated by asexual reproduction, and the characteristics of the “parent” are transmitted to its offspring with a probability of mutation applied to the dispersal parameters only (see “Reproduction”). 
### 2. Emergence
We purposely avoided implementing differences in dispersal abilities between the two phenotype classes, “Dispersers” and “Residents” since we were interested by the emergence of the differences between their respective dispersal syndromes. The only difference that is implemented between “Dispersers” and “Residents” is about their ability to beneficiate from being an immigrant or a native from a given patch, and the costs of dispersal (details are given in Table 1.). These differences are fixed throughout the simulation, are inherited by offspring and are not subject to mutation.

 
A beauty of IBM is that Fitness does not have to be inferred from some indirect measure: the size of the offspring of each individual and its age are basic variables accessible directly. Here we measure Fitness as the size of the individuals’ offspring at his death divided by the maximal fitness of all the metapopulation (i.e. relative fitness). The Fitness of a given individual shall emerge as a consequence of the interaction between its own characteristics, the environmental conditions and the characteristics of its competitors. Just like in real biological systems, individuals whose traits convey better success have more offspring, and their traits are more likely to spread in the population.
### 3. Sensing
Simulated individuals are able to detect the ground cover of the cell in which they are and behave accordingly. When performing the “perceptual range” submodel (during dispersal), they also detect the ground cover of all cells around them, in a radius corresponding to their perceptual range (variable between individuals). Individuals located in a “habitat” cell can also detect if this cell is empty or full of resource. Individuals cannot detect each other or get direct information about the population density in their patch.
### 4. Interaction
No direct interaction between individuals is implemented. However, individuals interact indirectly via scramble competition (cf. 1., Basic and Ecological Principles).
### 5. Stochasticity
Stochasticity is included in several procedures of the model. When dispersing, individuals choose their directions at random (with some exceptions like perceptual range, cf. Vi., Submodels). At reproduction, mutation of some characters occurs randomly with a specified frequency (see “reproduction” submodel). Individuals hitting a patch boundary emigrate randomly with an individual-specific frequency.  
(See also v., “Initialisation”).
### 6. Observation
Along each simulation, information is stored about the “population” size of Disperser and Residents, their respective mean Fitness, mean perceptual distance, mean emigration propensity, and mean sinuosity. Perceptual distance, emigration propensity, sinuosity in habitat and sinuosity in matrix are collected from the individual state variables, not analyzed from their paths. 
Being an adaptive dynamics models, values for each of the parameters of interest are likely to vary widely during the simulation until population stabilize, therefore we used only values from the end of the simulation in our analyses. 
### 7. Other ODD concepts
The following concepts originally included in the ODD protocol are not relevant here: (1) Adaptation and (2) Objectives: Simulated individuals do not aim at increasing any measure of success (see Emergence for a discussion on Fitness simulation). (2) Learning: Individuals don’t change their adaptive traits as a consequence of their experience. (3) Collectives: individuals do not form aggregations.  
## v.  Initialisation
Each simulation begins with an initial seed of 1000 individuals, randomly distributed among the centres of habitat patches. Individuals are located at the centre of the patches to avoid random effects. The internal parameters of interest are chosen at random for each individual in a uniform distribution. Individuals are randomly attributed to “Dispersers” or “Residents”. 

We varied only the number of habitat patches available in the landscape between the simulations (2 to 20 patches, 4% to 40% of the total area) to test the effect of the two main and intrinsically linked components of fragmentation sensu lato (habitat loss and connectivity loss) on the dispersal syndromes. We did not tested fragmentation levels below 40% because in our simulated system this would have lead to aggregation of patches and therefore to heterogeneity in patch sizes and gaps between patches. 
Five series of neutral landscapes with increasing fragmentation levels were designed as follow: (1) five different landscapes were obtained by randomly distributing 20 patches with a minimal distance of 4 pixels between them (border to border distance) (2) each landscape was declined by successively removing the patch with the closest neighbours. For each of the 19 fragmentation levels, 50 simulations were run with each of the 5 neutral landscapes. The 4750 simulations took approximately 5 days to run on a single computer (2-core, 2Ghz).
Preliminary simulations were performed in order to select the best combination of the other parameters available in the model (Table 1). Those parameters were chosen in order to keep the mean fitness as constant as possible and more importantly, as similar as possible between “Dispersers” and “Residents” (Fig. 3). 

Figures 3 to 5 and Annex 1 are based on a selection of simulations where both phenotypes where still present at the end of the 5000t (simulations where one phenotype is fixed – cf. Figure 1 – are not retained for the corresponding figures). New simulations were performed until 5x50 simulations were selected based on this criterion, for each fragmentation level.

## vi. Submodels
### 1. Resource consumption
When an individual arrives to a patch cell full of resources, it eats the resources and the cell becomes empty. If two or more individuals arrive to the same cell at the same time, the one who can eat the cell is chosen at random. If an individual is in an empty cell, it loses a variable quantity of energy (Table 1, Competition cost). 
### 2. Re-growing resources in habitat cells
Since a habitat cell is eaten, it may re-grow at each time step with a probability of 3%.
### 3. Dispersal
At each time step, each individual moves to one of its neighbour cells (Moore neighbours). If it is a matrix cell and the previous was habitat, it moves to the matrix cell with a probability Ep (Emigration Propensity) or turn back.  When an individual moves in habitat or in matrix, the probability that it changes direction at each time step is defined by is internal sinuosity parameters (sinuosity in habitat and sinuosity in matrix). When moving in the matrix, an individual “reads” the habitat quality of every cell in a radius corresponding to its perceptual range. When it detects a habitat cell, it heads toward. Movement in empty habitat cells and in matrix cells cost a variable amount of energy, depending of individual’s status (TABLE 1.). 
### 4. Reproduction
Individuals are allowed to reproduce as soon as they reach a given amount of energy reserves (Annex 1.). Reproduction is asexual. The energy of the “mother” is equally divided between mother and offspring. A reproducing individual “creates” a new one and its characteristics are inherited by the new individual. A notable exception concerns the dispersal characteristics that may mute with a probability Mp=1.e-4. Mutation means that a new value for the concerned parameter is chosen at random. 
### 5. Mortality
Mortality occurs when an individual exhausted its internal energy reserves. Before dying, it sends its age and offspring for Observer to calculate mean population fitness.




## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## Maps and files management

In order for the save and load procedures to work, you need to create a folder named "cartes" and place it in the same folder as your model file (the "model_name.nlogo").


## Things to notice

Fragmentation : below 40% this leads to aggregation of patches (i.e. two patches make a big one with scrambled ID's) and therefore to heterogeneity in patch sizes and gaps between patches. For example, 16 patches with a 10 pixel radius overlap : this hould probably be avoided. This is what the "check-overfit" is for.



## CREDITS AND REFERENCES
This model has been designed and programmed by Thomas Delattre (thomas.delattre@avignon.inra.fr) with help from Michel Baguette.

Delattre, T. & Baguette, M. (XXXX) Evolution of dispersal syndromes. Journal, Volume, Pages
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="sensi dynamique pop" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-landscape
setup-turtles</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>count turtles</metric>
    <metric>mean [sinuosity-in] of turtles</metric>
    <metric>mean [sinuosity-out] of turtles</metric>
    <metric>mean [reluctance] of turtles</metric>
    <enumeratedValueSet variable="Sinuosity-out-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Frequency">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="meteor?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-slider">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-slider">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-slider">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-range-slider">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perceptual-range?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-turtles">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-patches">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch-energy">
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-turtles">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberDestroyed">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perception-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pen-value">
      <value value="&quot;down&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-field-slider">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taille-patch">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MeanDist">
      <value value="95"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="r?p?tabilit?" repetitions="30" runMetricsEveryStep="false">
    <setup>setup-landscape
setup-turtles</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>count turtles</metric>
    <metric>[sinuosity-in] of turtles</metric>
    <metric>[sinuosity-out] of turtles</metric>
    <metric>[reluctance] of turtles</metric>
    <enumeratedValueSet variable="Sinuosity-out-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Frequency">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="meteor?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-slider">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-slider">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-slider">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-range-slider">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perceptual-range?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-turtles">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-patches">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-turtles">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberDestroyed">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perception-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-from-grass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pen-value">
      <value value="&quot;up&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-field-slider">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taille-patch">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MeanDist">
      <value value="95"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup-landscape
setup-tortoises</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>count tortoises with [status = "disperser"]</metric>
    <metric>count tortoises with [status = "resident"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "disperser"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>MeanFitnessAtDeath_R</metric>
    <metric>MeanFitnessAtDeath_D</metric>
    <enumeratedValueSet variable="ResidentMatrixCost">
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeLimit?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeHatchEnergy">
      <value value="7.5"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-patches">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perception-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ShowLinks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LimitPerceptualDistance">
      <value value="&quot;Min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigHatchEnergy">
      <value value="7.5"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Frequency">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeHatchEnergy">
      <value value="7.5"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigCompetitionCost">
      <value value="1.8"/>
      <value value="2"/>
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perceptual-range?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-IN_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigCompetitionCost">
      <value value="1.8"/>
      <value value="2"/>
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MinimalDist">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberDestroyed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-range-slider">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigGainFromFood">
      <value value="10"/>
      <value value="15"/>
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeCompetitionCost">
      <value value="1.8"/>
      <value value="2"/>
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeCompetitionCost">
      <value value="1.8"/>
      <value value="2"/>
      <value value="2.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeGainFromFood">
      <value value="10"/>
      <value value="15"/>
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserMatrixCost">
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FitnessMeasure">
      <value value="&quot;Multiple&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-OUT_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeGainFromFood">
      <value value="10"/>
      <value value="15"/>
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="check-overfit">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StatusMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-slider">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taille-patch">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REPULSION">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-slider">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigGainFromFood">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Percept_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TimeGap">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="meteor?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-slider">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Status-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeDeath">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigHatchEnergy">
      <value value="7.5"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pen-value">
      <value value="&quot;erase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ReluctanceMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-field-slider">
      <value value="186"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="NBpatchs" repetitions="50" runMetricsEveryStep="false">
    <setup>Load-Map
setup-tortoises</setup>
    <go>go</go>
    <final>file-close</final>
    <timeLimit steps="5000"/>
    <metric>count tortoises with [status = "disperser"]</metric>
    <metric>count tortoises with [status = "resident"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "disperser"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>MeanFitnessAtDeath_R</metric>
    <metric>MeanFitnessAtDeath_D</metric>
    <metric>DiffFitnessLiss</metric>
    <enumeratedValueSet variable="UserFileMap">
      <value value="&quot;cartes//p20s8md4_3&quot;"/>
      <value value="&quot;cartes//p19s8md4_3&quot;"/>
      <value value="&quot;cartes//p18s8md4_3&quot;"/>
      <value value="&quot;cartes//p17s8md4_3&quot;"/>
      <value value="&quot;cartes//p16s8md4_3&quot;"/>
      <value value="&quot;cartes//p15s8md4_3&quot;"/>
      <value value="&quot;cartes//p14s8md4_3&quot;"/>
      <value value="&quot;cartes//p13s8md4_3&quot;"/>
      <value value="&quot;cartes//p12s8md4_3&quot;"/>
      <value value="&quot;cartes//p11s8md4_3&quot;"/>
      <value value="&quot;cartes//p10s8md4_3&quot;"/>
      <value value="&quot;cartes//p9s8md4_3&quot;"/>
      <value value="&quot;cartes//p8s8md4_3&quot;"/>
      <value value="&quot;cartes//p7s8md4_3&quot;"/>
      <value value="&quot;cartes//p6s8md4_3&quot;"/>
      <value value="&quot;cartes//p5s8md4_3&quot;"/>
      <value value="&quot;cartes//p4s8md4_3&quot;"/>
      <value value="&quot;cartes//p3s8md4_3&quot;"/>
      <value value="&quot;cartes//p2s8md4_3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Frequency">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Percept_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigGainFromFood">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perception-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MinimalDist">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-OUT_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pen-value">
      <value value="&quot;erase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-IN_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-range-slider">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigGainFromFood">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeLimit?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REPULSION">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ReluctanceMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LimitPerceptualDistance">
      <value value="&quot;Min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeDeath">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentMatrixCost">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-slider">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ShowLinks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StatusMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-slider">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-patches">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taille-patch">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="check-overfit">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perceptual-range?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeGainFromFood">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FitnessMeasure">
      <value value="&quot;Absolute&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="meteor?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Status-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TimeGap">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserMatrixCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-field-slider">
      <value value="186"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-slider">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberDestroyed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeGainFromFood">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>Load-Map
setup-tortoises</setup>
    <go>go</go>
    <final>file-close</final>
    <timeLimit steps="5000"/>
    <metric>count tortoises with [status = "disperser"]</metric>
    <metric>count tortoises with [status = "resident"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "disperser"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>MeanFitnessAtDeath_R</metric>
    <metric>MeanFitnessAtDeath_D</metric>
    <metric>DiffFitnessLiss</metric>
    <enumeratedValueSet variable="DisperserImmigGainFromFood">
      <value value="16"/>
      <value value="18"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-slider">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-rate">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-patches">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Percept_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UserFileMap">
      <value value="&quot;cartes//p6s8md4_3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-slider">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigGainFromFood">
      <value value="8"/>
      <value value="10"/>
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Frequency">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REPULSION">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeHatchEnergy">
      <value value="8"/>
      <value value="10"/>
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perceptual-range?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-OUT_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserMatrixCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeGainFromFood">
      <value value="13"/>
      <value value="15"/>
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeLimit?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberDestroyed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeDeath">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-slider">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-range-slider">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StatusMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ReluctanceMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TimeGap">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ShowLinks?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MinimalDist">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="meteor?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perception-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FitnessMeasure">
      <value value="&quot;Absolute&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-field-slider">
      <value value="186"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-IN_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentMatrixCost">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pen-value">
      <value value="&quot;erase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="check-overfit">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch--size">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Status-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeGainFromFood">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LimitPerceptualDistance">
      <value value="&quot;Min&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="CostCalibration" repetitions="1" runMetricsEveryStep="true">
    <setup>setup-landscape
setup-tortoises</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="patch--size">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-patches">
      <value value="16"/>
    </enumeratedValueSet>
    <steppedValueSet variable="DisperserMatrixCost" first="0.8" step="0.1" last="1.2"/>
    <steppedValueSet variable="residentMatrixCost" first="0.8" step="0.1" last="1.2"/>
    <enumeratedValueSet variable="DisperserHomeHatchEnergy">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeGainFromFood">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeGainFromFood">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigGainFromFood">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigGainFromFood">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="meteor?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repulsion">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-IN_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ReluctanceMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-fixed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Percept_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeDeath">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TimeGap">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-range-slider">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perceptual-range?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UserFileMap">
      <value value="&quot;cartes//p6s8md4_3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentMatrixCost">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-slider">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-slider">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LimitPerceptualDistance">
      <value value="&quot;Min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="check-overfit">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ShowLinks?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-field-slider">
      <value value="186"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-rate">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Status-fixed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutations?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-slider">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-fixed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perception-fixed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-OUT_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberDestroyed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StatusMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-fixed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeLimit?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pen-value">
      <value value="&quot;erase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MinimalDist">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Frequency">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FitnessMeasure">
      <value value="&quot;Absolute&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="NBpatchs2" repetitions="500" runMetricsEveryStep="false">
    <setup>Load-Map
setup-tortoises
print date-and-time</setup>
    <go>go</go>
    <final>file-close
print count tortoises with [status = "disperser"]</final>
    <timeLimit steps="5000"/>
    <exitCondition>count tortoises with [status = "disperser"] &lt;= 0 or count tortoises with [status = "resident"] &lt;= 0</exitCondition>
    <metric>count tortoises with [status = "disperser"]</metric>
    <metric>count tortoises with [status = "resident"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "disperser"]</metric>
    <metric>mean lput 0 [sinuosity-out] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [sinuosity-in] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>mean lput 0 [reluctance] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "disperser"] + 0.0001</metric>
    <metric>mean lput 0 [perceptual-range] of tortoises with [status = "resident"] + 0.0001</metric>
    <metric>MeanFitnessAtDeath_R</metric>
    <metric>MeanFitnessAtDeath_D</metric>
    <metric>DiffFitnessLiss</metric>
    <metric>100 - ((count patches with [patch-type = "habitat"] / count patches with [patch-type = "matrix"]) * 100)</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="UserFileMap">
      <value value="&quot;cartes//p20s8md4_3&quot;"/>
      <value value="&quot;cartes//p19s8md4_3&quot;"/>
      <value value="&quot;cartes//p18s8md4_3&quot;"/>
      <value value="&quot;cartes//p17s8md4_3&quot;"/>
      <value value="&quot;cartes//p16s8md4_3&quot;"/>
      <value value="&quot;cartes//p15s8md4_3&quot;"/>
      <value value="&quot;cartes//p14s8md4_3&quot;"/>
      <value value="&quot;cartes//p13s8md4_3&quot;"/>
      <value value="&quot;cartes//p12s8md4_3&quot;"/>
      <value value="&quot;cartes//p11s8md4_3&quot;"/>
      <value value="&quot;cartes//p10s8md4_3&quot;"/>
      <value value="&quot;cartes//p9s8md4_3&quot;"/>
      <value value="&quot;cartes//p8s8md4_3&quot;"/>
      <value value="&quot;cartes//p7s8md4_3&quot;"/>
      <value value="&quot;cartes//p6s8md4_3&quot;"/>
      <value value="&quot;cartes//p5s8md4_3&quot;"/>
      <value value="&quot;cartes//p4s8md4_3&quot;"/>
      <value value="&quot;cartes//p3s8md4_3&quot;"/>
      <value value="&quot;cartes//p2s8md4_3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Frequency">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Percept_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigGainFromFood">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perception-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MinimalDist">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-OUT_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pen-value">
      <value value="&quot;erase&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-IN_MutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-range-slider">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigGainFromFood">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeLimit?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REPULSION">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ReluctanceMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LimitPerceptualDistance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="AgeDeath">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentMatrixCost">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-tortoises">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-out-slider">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ShowLinks?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-threshold">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="StatusMutationRate">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Reluctance-slider">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-patches">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="patch--size">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="check-overfit">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Perceptual-range?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeGainFromFood">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FitnessMeasure">
      <value value="&quot;Absolute&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="meteor?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Status-fixed?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TimeGap">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserMatrixCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutations?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserHomeCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigCompetitionCost">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perceptual-field-slider">
      <value value="186"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sinuosity-in-slider">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DisperserImmigHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentImmigCompetitionCost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberDestroyed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeGainFromFood">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ResidentHomeHatchEnergy">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
