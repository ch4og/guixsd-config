;;; Copyright © 2025 Nikita Mitasov <mitanick@ya.ru>
(define-module (modules substitutes))

(define-public substitutes
  '("https://mirror.yandex.ru/mirrors/guix"
    "https://mirror.sjtu.edu.cn/guix"
    "https://bordeaux.guix.gnu.org"
    "https://nonguix-proxy.ditigal.xyz"))

(define-public substitute-urls
  (string-append "--substitute-urls=\""
                 (string-join substitutes " ")
                 "\""))
