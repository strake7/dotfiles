begin
  c = IRB::Color
  token_seq_exprs = IRB::Color::const_get(:TOKEN_SEQ_EXPRS)

  # TODO: italics; see https://github.com/microsoft/vscode/issues/49236
  # TODO: how to customize method names (cyan or bold cyan I think?)
  # TODO: what about TOKEN_SEQ_KEYWORDS? do we care?
  color_mods = {
    on_comment: [c::CLEAR], # needs italics
    on_const:  [c::YELLOW, c::BOLD],
    on_label: [c::YELLOW],
    on_kw:  [c::MAGENTA],
    on_tstring_beg: [c::GREEN, c::BOLD],
    on_tstring_content: [c::GREEN],
    on_tstring_end: [c::GREEN, c::BOLD],
  }

  color_mods.each_pair do |token, theme_colors|
    if stdconfig = token_seq_exprs[token]
      stdconfig[0] = theme_colors
    end
  end
end
