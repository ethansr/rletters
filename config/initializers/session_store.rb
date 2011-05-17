# coding: UTF-8

RLetters::Application.config.session_store :cookie_store, :key => '_rletters_session'
RLetters::Application.config.action_dispatch.session = {
  :key => '_rletters_session',
  :secret => 'jyslpr5zuk1gyzryk3sxpp415n49kwck8jwloh5v8hwza57uis75gfy3eqi7w5jc'
}
