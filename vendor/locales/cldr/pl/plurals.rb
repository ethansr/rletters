# -*- encoding : utf-8 -*-
{ :pl => { :i18n => {:plural => { :keys => [:one, :few, :many, :other], :rule => lambda { |n| n == 1 ? :one : [2, 3, 4].include?(n % 10) && ![12, 13, 14].include?(n % 100) ? :few : n != 1 && [0, 1].include?(n % 10) || [5, 6, 7, 8, 9].include?(n % 10) || [12, 13, 14].include?(n % 100) ? :many : :other } } } } }
