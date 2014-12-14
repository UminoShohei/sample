$code = ''
$keywords = {
	'+' => :add,
	'-' => :sub,
	'*' => :mul,
	'/' => :div,
	'%' => :mod,
	'(' => :lpar,
	')' => :rpar
}
# 式 := 項 (('+'|'-')項)*
# 項 := 因子 (('*'|'/')因子)*
# 因子 := 因子 (リテラル|'('式')')

def get_token()
	if $code =~ /\A\s*(#{$keywords.keys.map{|t|Regexp.escape(t)}.join('|')})/
		$code = $'
		return $keywords[$1]
	elsif $code =~ /\A\s*([0-9.]+)/
		$code = $'
		return $1.to_f
	elsif $code =~ /\A\s*\z/
		return nil
	end
	return :bad_token
end

def unget_token(token)
	if token.is_a? Numeric
		$code = token.to_s + $code
	else
		$code = $keywords.index(token) ? $keywords.index(token) + $code : $code
	end
end

def expression()
	result = term
	while true
		token = get_token
		unless token == :add or token == :sub
			unget_token token
			break
		end
		result = [token, result, term]
	end
	return result
end

def term()
	result = factor
	while true
		token = get_token
		unless token == :mul or token == :div
			unget_token token
			break
		end
		result = [token, result, factor]
	end
	return result
end

def factor()
	token = get_token
	minusflg = 1
	if token == :sub
		minusflg = -1
		token = get_token
	end
	if token.is_a? Numeric
		return token * minusflg
	elsif token == :lpar
		result = expression
		unless get_token == :rpar
			raise Exception, "unexpected token"
		end
		return [:mul, minusflg, result]
	else
		return Exception,"unexpected token"
	end
end

def eval(exp)
	if exp.instance_of?(Array)
 		case exp[0]
 		when :add
 			return eval(exp[1]) + eval(exp[2])
 		when :sub		
 			return eval(exp[1]) - eval(exp[2])
 		when :mul
 			return eval(exp[1]) * eval(exp[2])
 		when :div
 			return eval(exp[1]) / eval(exp[2])
 		end
 	else
 		return exp
 	end
end

loop {
	print 'exp> '
	$code = STDIN.gets # read
	if $code == "quir\n" then exit end
	ex = expression # eval
	p eval(ex) # print
}


