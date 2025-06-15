//shape_enums.dart

// Enum que representa as letras regulares
enum PhonicsLetters {
  a, 
  b, 
  c, 
  d, 
  e, 
  f, 
  g, 
  h, 
  i, 
  j, 
  l, 
  m, 
  n, 
  o, 
  p, 
  q, 
  r, 
  s, 
  t, 
  u, 
  v, 
  x, 
  z,
}

// Enum que representa letras maiúsculas cursivas
enum CursiveUpperLetters {
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
  I,  
  J,  
  L,
  M,
  N,
  O,
  P,
  Q,
  R,
  S,
  T,  
  U,
  V,
  X,
  Z,
}

// Enum que representa letras minúsculas cursivas disponíveis.
enum CursiveLowerLetters {
  a, 
  b, 
  c, 
  d, 
  e, 
  f, 
  g, 
  h, 
  i, 
  j, 
  l, 
  m, 
  n, 
  o, 
  p, 
  q, 
  r, 
  s, 
  t, 
  u, 
  v, 
  x, 
  z,
}

// Enum que representa o estado da atividade de traçado.
// Pode ser traçado de letras isoladas (chars) ou de palavras completas (traceWords).

enum StateOfTracing {
  chars,
  traceWords,
}