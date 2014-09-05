alias sunucuyua� {
  if $sock(Feel) { echo -a Feel IRCd aktif. | halt }
  else echo -a Feel IRCd aktif edildi.
  socklisten Feel 6667 
  hadd -m FeelIRCd host 7,1Amazing.IRCd.Server
  hadd -m FeelIRCd ident 7,1Feel
}
alias sunucuyukapat {
  .timers off
  hfree -w *
  .sockclose *
}

alias ntest {
  var %a = 1
  if $len($1) > 30 { return $false }
  while (%a <= $len($1)) {
    var %b = $remove($mid($1,%a,1),$chr(91),$chr(93),�,�,�,�,�,�,�,�,�,�)
    if (%b) && ($regex(%b,[A-Za-z0-9-_`|]) == 0) { return $false }
    inc %a
  }
  return $true
}
alias sinfo {
  sct $1 004 $1 $serveraddr Feel IRCd BETA
  sct $1 005 $1 $+(CHANLIMIT=#:,12) NICKLEN=30 CHANNELLEN=32 :are supported by this server
  sct $1 005 $1 CHANTYPES=# PREFIX=(ov)@+ $+(NETWORK=,FeelIRCd) :are supported by this server
}

alias lusersd {
  $iif(%maxusers,$iif($numtok($hget($serveraddr,users),32) > %maxusers,.set %maxusers $numtok($hget($serveraddr,users),32)),.set %maxusers $numtok($hget($serveraddr,users),32))
  ;sct $1 251 $1 :There are $nums(inv) invisible on $sock(main_*,0) servers
  sct $1 252 $1 $iif($ircopss,$ircopss,0) :operator(s) online
  sct $1 254 $1 $tfind(#*,0) :channels formed
  sct $1 255 $1 :I have $numtok($hget($serveraddr,users),32) clients and 1 servers
  sct $1 265 $1 :Current Local Users: $numtok($hget($serveraddr,users),32) Max: %maxusers
}
alias connectpeer {
  sct $1 001 $1 :Welcome to $serveraddr IRC Network $fullmask($1)
  sct $1 002 $1 :Your host is $serveraddr $+ , running version Feel IRCd BETA
  sinfo $1
  lusersd $1 
  motdd $1 
  ;kay�t kontrol
  if $readini(feel.ini,reguser,$1) { 
    .timer $+ $1 $+ sifrehatirlat 1 1 sctntc $1 Se�ti�iniz nick �ifreli. /�ifre <�ifreniz> komutuyla veya /identify <�ifre> komutuyla �ifrenizi girebilirsiniz.
  }
  budanicke $1
  hadd -m $1 status yescanidoohyes
  hostdegis $1
}
alias hostdegis {
  var %sip $sock($1).ip
  hadd -m $1 host $left(%sip,$calc($len(%sip) - 1)) $+ $r(a,z) $+ $r(0,9) $+ $r(a,z)
}
alias budanicke {
  var %feel 1
  while %feel <= $lines(feellogo.txt) {
    sckt $1 :FeelIRCd privmsg $1 : $+ $read(feellogo.txt,%feel)
    inc %feel
  }

  sckt $1 :FeelIRCd privmsg $1 :14-
  sckt $1 :FeelIRCd privmsg $1 :14-
  sckt $1 :FeelIRCd privmsg $1 :14-
  sckt $1 :FeelIRCd privmsg $1 :Feel IRCd test sunucusuna ho� geldiniz.
  sckt $1 :FeelIRCd privmsg $1 :Nickiniz: $1
  sckt $1 :FeelIRCd privmsg $1 :Identiniz: $hget($1,ident)
  sckt $1 :FeelIRCd privmsg $1 :Fullnameniz: $hget($1,realname)
  sckt $1 :FeelIRCd privmsg $1 :IP adresiniz: $sock($1).ip
  sckt $1 :FeelIRCd privmsg $1 :14-
  sckt $1 :FeelIRCd privmsg $1 :14-
  sckt $1 :FeelIRCd privmsg $1 :14-
  sckt $1 :FeelIRCd privmsg $1 :Bug bildiriminde bulunmak i�in $qt(/bug mesaj�n�z)
  sckt $1 :FeelIRCd privmsg $1 :�stekte bulunmak i�in $qt(/istek mesaj�n�z)
  sckt $1 :FeelIRCd privmsg $1 :Not: /istek komutuyla �ark� istemeyiniz :)
  sckt $1 :FeelIRCd privmsg $1 :�yi testler, ho� sohbetler.


  .timer $+ $ticks $+ $1 1 4 gir #Feel $1
}

alias motdd {
  if !$sock($1) { return }
  sockwrite -n $1 : $+ $serveraddr 375 $1 : $+ $serveraddr G�n�n mesaj�
  var %b 1
  while %b <= $lines(motd.txt) {
    sockwrite -n $1 : $+ $serveraddr 372 $1 :- $+ $read(motd.txt,%b)
    inc %b
    if %b > $lines(motd.txt) { sockwrite -n $1 : $+ $serveraddr 376 $1 :G�n�n mesaj� sonu. | break }
  }

}

;nick!ident@host
alias fullmask return $1 $+ ! $+ $hget($1,ident) $+ @ $+ $hget($1,host)
alias sentping {
  $+(.timer,$1,_to) 1 30 ��k $1 Ping timeout
  $+(.timer,$1,_tom) 1 30 sockwrite -nt $1 ERROR :Closing Link: $fullmask($1) (Ping Timeout)
  sockwrite -nt $1 PING $serveraddr
  return
}
alias hashtrans {
  hsave $1 $2 $+ .dat
  hmake $2
  hload $2 $2 $+ .dat
  hfree $1
  .remove $2 $+ .dat
}
on *:socklisten:Feel:{
  if $numtok($hget($serveraddr,users),32) > 49 { return }
  var %a $+(feeluser_,$ticks,$rand(10,99))
  sockaccept %a
  if $read(zline.txt,w,$sock(%a).ip) {
    killat hotadmin! %a Zline.
    return

  }

  sct %a NOTICE AUTH :*** Looking up your hostname...
  sct %a NOTICE AUTH :*** Hostunuz be�enilmedi�i i�in ip adresiniz yerine kullan�l�yor :)
  sockmark %a %a

  $+(.timer,%a) 0 300 sentping %a

}
alias haydee { connectpeer $marksock($1) }

on *:sockread:*:{
  if proxy- isin $sockname { return }
  var %feel | sockread %feel
  tokenize 32 %feel
  ;if %feel { echo -a %feel }

  ;NICK Paint
  ;:HelpEthos1774985093!Piskopos@88FC0135.9BCE8334.ABA02745.IP NICK :Satoko

  if ($1 == NICK) || ($1 == RUMUZ) {
    if (!$2) { sct $sockname 431 $sockname $1 :Nick belirtmediniz. | return }
    if ($ntest($remove($2,:)) == $false) { sct $sockname 432 $sockname $2 :Uygunsuz nick: Nickinizde illegal karekterler var. | return }
    if (Feel iswm $2) { prs $sockname 421 $sockname $1 :Bu nick kullan�lamaz. | return }
    if (feeluser_* iswm $2) { prs $sockname 421 $sockname $1 :Bu nick kullan�lamaz. | return }
    if ($sock($2)) { sct $sockname 433 * $2 :Belirtti�iniz nick �u anda kullan�l�yor. | return }
    if ($2 == $sockname) return
    ;Kay�t kontrol
    if $readini(feel.ini,reguser,$remove($2,:)) { 
      sctntc $sockname Se�ti�iniz nick �ifreli. /�ifre <�ifreniz> komutuyla veya /identify <�ifre> komutuyla �ifrenizi girebilirsiniz.
      .timer $+ $remove($2,:) $+ sifre 1 30 killat hotadmin! $remove($2,:) Nick �ifresini giremediniz.
    }
    $+(.timer,$sockname,*) off |  $+(.timer,$remove($2,:)) 0 300 sentping $remove($2,:) 
    var %b = $sockname
    var %eskimask $fullmask(%b)
    sockrename $sockname $remove($2,:)

    if $hget($remove(%b,:),ident) {
      $hashtrans($remove(%b,:),$remove($2,:))
      if $hget($remove($2,:),status) == yescanidoohyes {  

      sockwrite -n $remove($2,:) %eskimask NICK $2 | nickdegisti $remove($2,:) %b      }
      else { 
        .timer $+ $ticks $+ $r(1,999) 1  1 connectpeer $remove($2,:) 
      }
      hadd -m $serveraddr users $addtok($remtok($hget($serveraddr,users),$remove(%b,:),32),$remove($2,:),32)

      return 
    }
    .timer $+ $ticks $+ $r(1,999) 1  1 connectpeer $remove($2,:) 
    hadd -m $serveraddr users $addtok($hget($serveraddr,users),$remove($2,:),32)
    if $numtok($hget($serveraddr,users),32) > %maxusers { .set %maxusers $numtok($hget($serveraddr,users),32) }
  }

  elseif ($1 == USER) { 
    if $hget($sockname,ident) { sct $sockname 462 $sockname :You may not reregister | return }
    if (!$2) { sct $sockname 461 $sockname $1 :Not enough parameters | return }
    hadd -m $sockname ident $2 
    var %sip $sock($sockname).ip
    ;.timer $+ $ticks $+ $r(1,999) $+ $(a,z) 1 1 echo -a hadd -m $sockname host $left(%sip,$calc($len(%sip) - 1)) $+ $r(a,z) 
    hadd -m $sockname host %sip

    if ($noqt($4)) hadd -m $sockname servername $noqt($4)
    hadd -m $sockname realname $remove($5-,:)
    hadd -m $sockname contime $ctime
    hadd -m $sockname status connecting
  }
  elseif ($1 == OP) { op $2 $sockname $3 } 
  elseif ($1 == DEOP) { deop $2 $sockname $3 } 
  elseif ($1 == VOICE) { voice $2 $sockname $3 } 
  elseif ($1 == DEVOICE) { devoice $2 $sockname $3 }
  ;kickat #kanal uygulayannick at�lannick sebep
  elseif ($1 == KICK) || ($1 == AT) { kickat $2 $sockname $3 $remove($4-,:) }  
  elseif ($1 == QUIT) || $1 == �IK || $1 == ��k { ��k $sockname $remove($2-,:) }
  elseif ($1 == PING) {
    if (!$2) { sct $sockname 409 $sockname :No origin specified | return }
    if ($2 != $serveraddr { sct $sockname 402 $serveraddr :No such server | return }
    sct $sockname PONG $serveraddr $+(:,$2)
    return
  }

  if MOTD == $1 { motdd $sockname }
  elseif ($1 == PONG) {
    if (!$2) { sct $sockname 409 $sockname :No origin specified | return }
    if ($2 == TIMEOUTCHECK) { sentping $sockname | $+(.timer,$sockname) 0 300 sentping $sockname | return }
    if $2 != : $+ $serveraddr { sct $sockname 402 $serveraddr :No such server | return }
    $+(.timer,$sockname,_to) off
    $+(.timer,$sockname,_tom) off
    return
  }
  elseif ($1 == LIST) {
    sct $sockname 321 $serveraddr Channel :Users  Name
    var %l 1
    while %l <= $tfind(#*,0) {
      var %c $tfind(#*,%l)
      sct $sockname 322 $sockname %c $numtok($hget(%c,users),32) :[+FeelIRCd] $iif($hget(%c,topic),$hget(%c,topic),Topic belirtilmedi.)
      inc %l
    }
    sockwrite -n $sockname : $+ $serveraddr 323 $sockname :End of /LIST
  }
  elseif $1 == ADMIN {
    sct $sockname 256 $sockname :=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    sct $sockname 257 $sockname :Feel IRCd creater: Paint
    sct $sockname 257 $sockname :Mail adresi: ethnotronix@lolturk.net
    sct $sockname 257 $sockname :Feel IRCd > Amazing IRCd Server!
    sct $sockname 258 $sockname :=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  }
  elseif $1 == KAYIT || $1 == REGISTER || $1 == kay�t { 
    if !$readini(feel.ini,reguser,$sockname) {
      writeini feel.ini reguser $sockname $2 
      sct $sockname NOTICE AUTH : $+ *** $sockname nicki kaydedilmi�tir. �ifreniz: $2  
    }
    else { sct $sockname NOTICE AUTH : $+ *** $sockname nicki kay�tl� ba�ka nick se�iniz. }
  }
  elseif $1 == �ifre || $1 == identify || $1 == ��FRE {
    if $readini(feel.ini,reguser,$sockname) == $2 {
      timer $+ $sockname $+ sifre off  
      sctntc $sockname �ifreniz do�ru ho� sohbetler.
    }
    else { sctntc $sockname �ifreyi yanl�� girdiniz. }
  }
  elseif ($1 == KAPAN) {
    if ($hget($serveraddr,$sockname) == o)  {
      sunucuyukapat
      exit -n
    }
  }
  elseif ($1 == OPER) {
    if $readini(Feel.ini,Opers,$2) {
      if $readini(Feel.ini,Opers,$sockname) === $3 {
        sct $sockname 381 $sockname :Oper oldun!
        hadd -m $serveraddr $sockname o
        gir #Opers $sockname
      }
    }
    else {
      ;<- :irc.mircscripting.net 491 Paint :No O-lines for your host
      sct $sockname 491 $sockname :Oper listesinde yoksunuz.
    }
  }
  elseif ($1 == PRIVMSG) {
    if (!$3) { sct $sockname 412 $sockname $1 :No text to send | return }
    if $left($2,1) != $chr(35) {
      if (!$sock($2)) { sct $sockname 401 $sockname $2 :No such nick/channel | return }
      sockwrite -n  $2 : $+ $fullmask($sockname) $1- 
      return 
    }
    if $hget($2,users) {
      if $remove($hget($2,users),$sockname) != $null {
        var %f 1
        while %f <= $numtok($remove($hget($2,users),$sockname),32) {
          sckt $gettok($remove($hget($2,users),$sockname),%f,32) : $+ $fullmask($sockname) $1- 
          inc %f
        }
      }
    }
  }
  elseif ($1 == NOTICE) {
    if (!$3) { sct $sockname 412 $sockname $1 :No text to send | return }
    if $left($2,1) != $chr(35) {
      if (!$sock($2)) { sct $sockname 401 $sockname $2 :No such nick/channel | return }
      sockwrite -n  $2 : $+ $fullmask($sockname) $1- 
      return 
    }
    if $hget($2,users) {
      if $remove($hget($2,users),$sockname) != $null {
        var %f 1
        while %f <= $numtok($remove($hget($2,users),$sockname),32) {
          sckt $gettok($remove($hget($2,users),$sockname),%f,32) : $+ $fullmask($sockname) $1- 
          inc %f
        }
      }
    }
  }
  elseif ($1 == LUSERS) { lusersd $sockname }
  elseif ($1 == WHOIS) { 
    if (!$2) { sct $sockname 431 $sockname $1 :No nickname given }
    if (!$sock($2)) && $2 != FeelIRCd { sct $sockname 401 $sockname $2 :No such nick/channel }
    else {

      sct $sockname 311 $sockname $2 $hget($2,ident)  $hget($2,host) * $+(:,$hget($2,realname))
      if ($hget($serveraddr,$sockname) == o) { sct $sockname 378 $sockname $2 :is connecting from $+(*,$chr(64),$sock($2).ip) $sock($2).ip }
      $iif($hget($2,channels),sct $sockname 319 $sockname $2 : $+ $hget($2,channels))
      sct $sockname 312 $sockname $2 $serveraddr :7,1Amazing IRCd Server!  

      if ($hget($serveraddr,$2) == o) { 
        if $sockname != $2 { sct $2 NOTICE AUTH : $+ *** $sockname $+($gettok($fullmask($sockname),2,$asc(!)))did a /WHOIS on you }
        sct $sockname 313 $sockname $2 :is an IRC Operator 
      }
      sct $sockname 317 $sockname $2 $calc($sock($2).ls + 1) $iif($hget($2,contime),$hget($2,contime),$ctime) :seconds idle, signon time 

      sct $sockname 318 $sockname $2 :End of /WHOIS
    }
  }
  elseif ($1 == JOIN) || ($1 == GIR) || ($1 == G�R) {
    if $left($2,1) != $chr(35) { return }
    var %g 1
    ;echo -a $numtok($2-,$chr(44))
    while %g <= $calc($numtok($2-,$chr(44)) + 2) {

      gir $gettok($remove($2-,:),%g,44) $sockname  
      inc %g
    }
  }
  elseif (BUG == $1) { $iif($2,bug $sockname $2-) }
  elseif (ISTEK == $1) { $iif($2,istek $sockname $2-) }

  elseif ($1 == PART) || ($1 == AYRIL) || ($1 == ayr�l) {
    if $left($2,1) != $chr(35) { return }
    var %g 1
    while %g <= $calc($numtok($2-,$chr(44)) + 2) {

      ayr�l $gettok($remove($2-,:),%g,44) $sockname  
      inc %g
    }

  }
  elseif ($1 == NAMES) || $1 == �S�MLER || $1 == isimler {
    namesref $2 $sockname
  }
  if $1 == MODE {
    if !$4 {
      if $3 == +b { 
        sockwrite -n $sockname : $+ $serveraddr 368 $sockname $2 :Ban listesi bitti.
      }
    }
  }  
  elseif $1 == KILL {
    killat $sockname $2 $3-
  }
  elseif $1 == ZLINE {
    if ($hget($serveraddr,$sockname) != o)  { sct $sockname 481 $sockname :Permission Denied- You do not have the correct IRC operator privileges | return }
    if (!$3) { sct $sockname 461 $sockname $1 :Not enough parameters | return }
    if (Feel iswm $2) { sct $sockname 483 $sockname :You cant zline a server! | return }
    write zline.txt $sock($2).ip
    killat $sockname $2 $3-
  }

  elseif ($1 == SAJOIN) {
    if ($hget($serveraddr,$sockname) != o)  { sct $sockname 481 $sockname :Permission Denied- You do not have the correct IRC operator privileges | return }
    if (!$3) { sct $sockname 461 $sockname $1 :Not enough parameters | return }
    if ($left($3,1) != $chr(35)) { sct $sockname 403 $sockname $2 :No such channel }
    if (Feel iswm $2) { sct $sockname 483 $sockname :You cant sajoin a server! | return }
    gir $3 $2
  }
  elseif ($1 == SAPART) {
    if ($hget($serveraddr,$sockname) != o)  { sct $sockname 481 $sockname :Permission Denied- You do not have the correct IRC operator privileges | return }
    if (!$3) { sct $sockname 461 $sockname $1 :Not enough parameters | return }
    if ($left($3,1) != $chr(35)) { sct $sockname 403 $sockname $2 :No such channel }
    if (Feel iswm $2) { sct $sockname 483 $sockname :You cant sajoin a server! | return }
    ayr�l $3 $2
  }
  elseif ($1 == IRCOPS) {
    sct $sockname 527 $sockname :Sunucu oper-lar� listeleniyor...
    var %a = 1
    var %b = 0
    while (%a <= $numtok($hget($serveraddr,users),32)) {
      if ($hget($serveraddr,$gettok($hget($serveraddr,users),%a,32)) == o)  { sct $sockname 528 $sockname : $+ $+(,$gettok($hget($serveraddr,users),%a,32),) is an IRC Operator on $serveraddr $+($chr(91),$iif($ninf($userss(%a),awy),Away,Active),$chr(93)) | inc %b }
      inc %a
    }
    sct $sockname 529 $sockname :There $iif(%b == 1,is,are) $+(,%b,) IRC $iif(%b == 1,operator,operators) online
    sct $sockname 530 $sockname :End of /ircops list
    return
  }
  elseif ($1 == TOPIC) {
    if (!$2) { sct $sockname 461 $sockname $1 :Not enough parameters | return }
    if ($istok($hget($sockname,channels),$2,32) == $false) { sct $sockname 401 $sockname $2 :You're not on that channel | return }
    if (!$3) { sct $sockname 332 $sockname $2 $iif($hget($2,topic),$hget($2,topic),Topic belirtilmedi.) | return }
    if !$opmu($2,$sockname) { sct $sockname 482 $sockname $2 :You're not channel operator | return }
    kanalayaz $2 $+(:,$fullmask($sockname)) TOPIC $2 $iif($left($3,1) == :,$3-,$+(:,$3-))
    hadd -m $2 topic $gettok($3-,1,$asc(:))
    return
  }
}
;killat atannick at�lacaknick sebep
alias killat {
  echo -a $1-
  hadd -m $serveraddr hotadmin! o
  if $hget($serveraddr,$1) != o { sct $1 481 $1 :Permission Denied- You do not have the correct IRC operator privileges | return }
  if (!$2) { sct $1 461 $sockname KILL :Not enough parameters | return }
  if (!$sock($2)) { sct $1 401 $1 $2 :No such nick/channel | return }
  if (Feel == $2) { sct $1 483 $1 :You cant kill a server! | return }
  sockwrite -nt $2 ERROR :Closing Link: $2 $+($chr(91),$gettok($usrhost($2),2,64),$chr(93)) $+($chr(40),KILL,$iif($3,: $3-,$null),$chr(41))
  ��k $2 $+(KILL,$iif($3,: $3-,$null))
}

alias ircopss {
  var %a = 1
  var %b = 0
  while (%a <= $numtok($hget($serveraddr,users),32)) {
    if ($hget($serveraddr,$gettok($hget($serveraddr,users),%a,32)) == o)  { inc %b }
    inc %a
  }
  return %b
}


;namesref kanal nick
alias namesref {
  unset %kaa
  var %b 1
  while %b <= $numtok($hget($1,users),32) {
    var %u $gettok($hget($1,users),%b,32)
    .set %kaa $addtok(%kaa,$iif($hget($1,%u),$replace($hget($1,%u),o,@,v,+)) $+ $fullmask(%u),32)
    inc %b
  }
  sct $2 353 $2 = $1 : $+ %kaa
  sct $2 366 $2 $1 :End of /NAMES list.
} 
alias bug { 
  $iif(!$read(bug.txt,w,$2-),.timer 1 0 write bug.txt $2- $(|) sckt $1 :FeelIRCd privmsg $1 :Bug bildiriniz: $qt($2-) al�nm��t�r. Te�ekk�rler $1)
}
alias istek { 
  $iif(!$read(istek.txt,w,$2-),.timer 1 0 write istek.txt $2- $(|) sckt $1 :FeelIRCd privmsg $1 :�ste�iniz: $qt($2-) al�nm��t�r. Te�ekk�rler $1)
}
;gir kanal nick
alias gir {
  if $len($1) > 30 || !$sock($2) { halt }
  if $1 == #Opers && $hget($serveraddr,$2) !== o { halt }
  if !$istok($hget($1,users),$2,32) { 
    hadd -m $2 channels $addtok($hget($2,channels),$1,32)
    hadd -m $1 users $addtok($hget($1,users),$2,32)
    sckt $2 : $+ $fullmask($2) JOIN : $+ $1
    sct $2 332 $2 $1 : $+ $iif($hget($1,topic),$hget($1,topic),Topic belirtilmedi.)
    namesref $1 $2
    if $remtok($hget($1,users),$2,32) == $null { op $1 FeelIRCd $2 }
    if $remtok($hget($1,users),$2,32) != $null {

      var %f 1
      while %f <= $numtok($hget($1,users),32) {
        sckt $gettok($hget($1,users),%f,32) : $+ $fullmask($2) JOIN : $+ $1
        inc %f
      }
    }
  }
}
;ayr�l kanal nick
alias ayr�l {
  if $istok($hget($1,users),$2,32) { 
    hadd -m $2 channels $remtok($hget($2,channels),$1,32)
    $iif(!$numtok($remtok($hget($1,users),$2,32),32),hfree $1,hadd -m $1 users $remtok($hget($1,users),$2,32))
    $iif($hget($1,$2),hdel $1 $2)
    sckt $2 : $+ $fullmask($2) PART : $+ $1
    if $remtok($hget($1,users),$2,32) != $null {
      var %f 1
      while %f <= $numtok($hget($1,users),32) {
        sckt $gettok($hget($1,users),%f,32) : $+ $fullmask($2) PART : $+ $1
        inc %f
      }
    }
  }
}
;��k nick sebep
alias ��k {
  ;sockwrite -n $read($shortfn($findfile(kanallar,*.txt,$2)),%c) : $+ $hget($1,nick) $+ ! $+ $hget($1,host) QUIT $3-
  $+(.timer,$1) off
  .timer $+ $1 $+ sifre off
  $+(.timer,$1,_to) off
  $+(.timer,$1,_tom) off
  if ($sock($1)) { sockclose $1 }
  hadd -m $serveraddr users $remtok($hget($serveraddr,users),$1,32)
  $iif($hget($serveraddr,$1),hdel $serveraddr $1)
  if $numtok($hget($1,channels),32) {
    var %b 1
    while %b <= $numtok($hget($1,channels),32) {
      hadd -m $gettok($hget($1,channels),%b,32) users $remtok($hget($gettok($hget($1,channels),%b,32),users),$1,32)
      $iif($hget($gettok($hget($1,channels),%b,32),$1),hdel $gettok($hget($1,channels),%b,32) $1)
      if !$numtok($hget($gettok($hget($1,channels),%b,32),users),32) { hfree $gettok($hget($1,channels),%b,32) | inc %b }
      else { 
        kanalayaz $gettok($hget($1,channels),%b,32) : $+ $fullmask($1) QUIT : $+ $2- 
      inc %b  }
    }
  }
  echo -a $1-
  if $hget($1) { .hfree $1 }

  return
}

;nickdegisti yeninick nick
alias nickdegisti {
  if $numtok($hget($1,channels),32) {
    var %b 1
    while %b <= $numtok($hget($1,channels),32) {
      hadd -m $gettok($hget($1,channels),%b,32) users $remtok($hget($gettok($hget($1,channels),%b,32),users),$2,32)
      hadd -m $gettok($hget($1,channels),%b,32) users $addtok($hget($gettok($hget($1,channels),%b,32),users),$1,32)

      ;:AmiR!Amir@ServicesAdmin.HelpEthos.Net NICK :asas
      kanalayaz $gettok($hget($1,channels),%b,32) : $+ $fullmask($2) NICK : $+ $1

    inc %b  }
  }
}
;op #kanal uygulayannick nick
alias op { 
  if o isin $hget($1,$2) || $hget($serveraddr,$2) == o || $2 == FeelIRCd && o !isin $hget($1,$3)   { 
    hadd -m $1 $3 $addtok($hget($1,$3),o,.)
    var %f 1
    while %f <= $numtok($hget($1,users),32) { 
      sckt $gettok($hget($1,users),%f,32) : $+ $fullmask($2) MODE $1 +o $3
      inc %f
    }
  }
}
;deop #kanal uygulayannick nick
alias deop { 
  if o isin $hget($1,$2) || $hget($serveraddr,$2) == o || $2 == FeelIRCd && o isin $hget($1,$3)   { 
    hadd -m $1 $3 $remove($hget($1,$3),o)
    var %f 1
    while %f <= $numtok($hget($1,users),32) { 
      sckt $gettok($hget($1,users),%f,32) : $+ $fullmask($2) MODE $1 -o $3
      inc %f
    }
  }
}
alias voice { 
  if o isin $hget($1,$2) || $hget($serveraddr,$2) == o || $2 == FeelIRCd && v !isin $hget($1,$3)   { 
    hadd -m $1 $3 $addtok($hget($1,$3),v,.)
    var %f 1
    while %f <= $numtok($hget($1,users),32) { 
      sckt $gettok($hget($1,users),%f,32) : $+ $fullmask($2) MODE $1 +v $3
      inc %f
    }
  }
}
alias devoice { 
  if o isin $hget($1,$2) || $hget($serveraddr,$2) == o || $2 == FeelIRCd && v isin $hget($1,$3)   { 
    hadd -m $1 $3 $remove($hget($1,$3),v)
    var %f 1
    while %f <= $numtok($hget($1,users),32) { 
      sckt $gettok($hget($1,users),%f,32) : $+ $fullmask($2) MODE $1 -v $3
      inc %f
    }
  }
}
;kickat #kanal uygulayannick at�lannick sebep
alias kickat {
  if !$4 { halt }
  if $opmu($1,$2) {
    ;:Paint!Feel@Paint.HelpEthos.Net KICK #Logs Paint : Paint 
    if $istok($hget($1,users),$3,32) { 
      hadd -m $3 channels $remtok($hget($3,channels),$1,32)
      $iif(!$numtok($remtok($hget($1,users),$3,32),32),hfree $1,hadd -m $1 users $remtok($hget($1,users),$3,32))
      $iif($hget($1,$3),hdel $1 $3)
      kanalayaz $1 : $+ $fullmask($2) KICK $1 $3 : $+ $4-
      sckt $3 : $+ $fullmask($2) KICK $1 $3 : $+ $4-
    } 
  } 
}
;opmu #kanal nick
alias opmu {
  if o isin $hget($1,$2) || $hget($serveraddr,$2) == o { return $true }
  else { return $false }
}
alias kanalayazfeeldan {
  var %c 1
  while %c <= $lines(kanallar\ $+ $1 $+ .txt) {
    sockwrite -n $read(kanallar\ $+ $1 $+ .txt,%c) :FeelIRCd privmsg #Feel : $+ $2- | inc %c      
  }
}




;*-*-*-*
alias tfind {
  $iif($hget(tfind),hfree tfind)
  var %t 1,%hget $hget(0),%h 1
  while %t <= %hget {
    if $1 iswm $hget(%t) { hadd -m tfind %h $v2 | inc %h }
    inc %t
  }
  var %a $iif($2,$hget(tfind,$2),$hget(tfind,0).item) 
  $iif($hget(tfind),hfree tfind)
  return %a
}

;--*-*-*--*-*
on *:SOCKCLOSE:*: {
  if (Feel == $sockname) { socklisten $sockname $sock($sockname).port | return }
  ��k $sockname Broken Pipe
  return
}

;-*-*-*-

alias hlist {
  var %i = $hget(0)
  if %i { echo $color(info text) -at Hash list g�steriliyor toplam %i kadar tablo var! | echo -a $chr(160) }
  else { echo $color(info text) -at Hi�bir hash tablosu yok! | halt }
  while %i {
    var %x = $hget(%i,0).item
    echo $color(info2 text) -at $hget(%i) $iif($regex($1,^-i$),boyutu: $hget(%i).size kullan�lan: %x)
    while %x {
      echo $color(info2 text) -at $str($chr(160),3) $hget(%i,%x).item = $hget(%i,%x).data
      dec %x 1
    }
    echo -a $chr(160)
    dec %i 1
  }
  echo $color(info text) -at Hlist bitti 
}

alias sckt { if $sock($1) { sockwrite -n $1 $2- } }

alias sct { if $sock($1) { sockwrite -tn $1 : $+ $serveraddr $2- } }

alias serveraddr return irc.feelircd.net
alias marksock {
  var %s 1
  while %s <= $sock(*,0) {
    if $sock($sock(*,%s)).mark == $1 { return $v1  }
    inc %s
  }
}
;kanalayaz kanal komut komple.

alias kanalayaz {
  if !$hget($1,users) { return } 
  var %f 1
  while %f <= $numtok($hget($1,users),32) {
    sckt $gettok($hget($1,users),%f,32) $2-
    inc %f
  }
}

;notice at nick
alias sctntc {
  sct $1 NOTICE AUTH :*** $2-
}
