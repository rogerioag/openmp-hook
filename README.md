# openmp-hook

Este projeto faz parte da tese de doutorado _A Runtime for Code Offloading on Modern Heterogeneous Platforms_. Descrevemos um _runtime_ relacionado com paralelização automática e _offloading_ de código baseado em versões de código para laços paralelos. A ideia é que o código de entrada seja um código `OpenMP` que pode ser gerado por um compilador ou que possa ser escrito manualmente.

O código de entrada é preparado com funções alternativas contendo versões de código do laço paralelo para cada um dos dispositivos aceleradores. As bibliotecas do _runtime_ implementado neste projeto interceptam algumas chamadas que as aplicações fazem ao _runtime_ do `OpenMP` usando uma técnica de _hooking_. A decisão sobre o _offloading_ de código é tomada automaticamente em tempo de execução usando a intensidade operacional que é obtida aplicando-se conceitos do __Modelo Roofline__. Estamos considerando medidas em todos os níveis da hierarquia de memória e as transferências de dados entre o host e os dispositivos aceleradores.

Neste projeto estão as implementações das bibliotecas da prova de conceito.
