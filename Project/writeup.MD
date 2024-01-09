- Papiro sui goal del computer performance evaluation (throughput vs response time)
- Fitting uso assignment 4
- C'era una entry a 0 nel video trace, l'ho rimorsa per il fitting

# Risultati Fitting

Compositing: o Hyper o Weibull o Exp
Audio Editing: Hyper
Video Editing: Hyper
VFX: Hyper

# Model

Lambdas are [1/days]

6 queue:

1) Writing: Erlang: K = 16 Lambda = 4
2) Shooting: Erlang: K = 9 Lambda = 3
3) Audio Editing: Hyper: L1 = 0.0542269 L2 = 0.216503 P1 = 0.20801
4) Video Editing: Hyper: L1 = 0.0492715 L2 = 0.19638 P1 = 0.194409
5) VFX: Hyper: L1 = 0.0405977 L2 = 0.160212 P1 = 0.204244
6) Compositing: Hyper: L1 = 0.288123 L2 = 4.98502 P1 = 0.998407

With a first run, it seems that the bottleneck is VFX. Inserting another VFX in parallel to the other one
the bottleneck becames the Video Editing Stage

# Risultati

Mostro 3 grafici delle utilization + Utilization Comparison per ogni step.

Uno step = Inserisco un nuovo server dove ho utilization bottleneck