function [f,o] = optimbench(id)

	% f: function
	% d: dimension of input
	% lb: lower bound
	% ub: upper bound
	% nc: number of constraints
	% g1, g2,...: function handles defining each constraint
	% g: final constraints function

	% initializing empty constaints
	nc = 0
	g = @() 0
	g1=[];g2=[];g3=[];g4=[];g5=[];g6=[];g7=[];g8=[];g9=[];g10=[];g11=[];g12=[]	
	
	id = lower(id)
	switch id
	
		case 'ackley' % https://en.wikipedia.org/wiki/Test_functions_for_optimization
			f = @(x) -20*exp(-0.2*sqrt(0.5*sum(x.^2,2))) - exp(0.5*(cos(2*pi*x(:,1))+cos(2*pi*x(:,2)))) + exp(1) + 20
			d = 2
			lb = -5	
			ub = 5			
			
		case 'beale' % http://www.geocities.ws/eadorio/mvf.pdf
			f = @(x) 	(1.5 - x(:,1) + x(:,1).*x(:,2)).^2 + ...
							(2.25 - x(:,1) + x(:,1).*x(:,2).^2).^2 + ...
							(2.625 - x(:,1) + x(:,1).*x(:,2).^3).^2
			d = 2
			lb = -4.5
			ub = 4.5			
			
		case 'bohachevsky1' % http://www.geocities.ws/eadorio/mvf.pdf
			f = @(x) x(:,1).^2 + 2*x(:,2).^2 - 0.3*cos(3*pi*x(:,1)) - 0.4*cos(4*pi*x(:,2)) + 0.7
			d = 2
			lb = -50
			ub = 50
		
		case 'bohachevsky2' % http://www.geocities.ws/eadorio/mvf.pdf
			f = @(x) x(:,1).^2 + 2*x(:,2).^2 - 0.3*cos(3*pi*x(:,1)).*cos(4*pi*x(:,2)) + 0.3
			d = 2
			lb = -50
			ub = 50
			
		case 'booth' % http://www.geocities.ws/eadorio/mvf.pdf
			f = @(x) (x(:,1) + 2*x(:,2) - 7).^2 + (2*x(:,1) + x(:,2) -5).^2
			d = 2
			lb = -10
			ub = 10
			
		case 'rosenbrock' %  https://en.wikipedia.org/wiki/Test_functions_for_optimization
			f = @(x) 100*(x(:,2)-x(:,1).^2).^2 + (x(:,1)-1).^2
			d = 2
			lb = -5	
			ub = 5	
	
		case 'viennet' %  https://en.wikipedia.org/wiki/Test_functions_for_optimization
			f = @(x) [	0.5*sum(x.^2,2) + sin(sum(x.^2,2)), ...
										(3*x(:,1)-2*x(:,2)+4).^2/8 + (x(:,1)-x(:,2)+1).^2/27 + 15, ...
										1./(sum(x.^2,2)+1) - 1.1*exp(-sum(x.^2,2)) ]
			d = 2
			lb = -5	
			ub = 5
	
		case 'sch'	% http://sci2s.ugr.es/sites/default/files/files/Teaching/OtherPostGraduateCourses/MasterEstructuras/bibliografia/Deb_NSGAII.pdf
			f = @(x) [sum(x.^2,2), sum((x-2).^2,2)]
			d = 1
			lb = -1000
			ub = 1000
			
		case 'kursawe'	% http://sci2s.ugr.es/sites/default/files/files/Teaching/OtherPostGraduateCourses/MasterEstructuras/bibliografia/Deb_NSGAII.pdf
			a = 0.8
			b = 3
			f = @(x) [	sum(-10*exp(-0.2*sqrt(x(:,1:end-1).^2 + x(:,2:end).^2)),2),... 
							sum(abs(x).^a + 5*(sin(x.^b)),2)]
			d = 3
			lb = -5
			ub = 5
			
		case 'constr'	% http://sci2s.ugr.es/sites/default/files/files/Teaching/OtherPostGraduateCourses/MasterEstructuras/bibliografia/Deb_NSGAII.pdf
			f = @(x) [x(:,1), (1+x(:,2))./x(:,1)]
			d = 2
			lb = [0.1 0]
			ub = [1 5]
			nc = 2
			g1 = @(x) x(:,2) + 9*x(:,1) - 6
			g2 = @(x) -x(:,2) + 9*x(:,1) - 1

		case 'srn' % http://sci2s.ugr.es/sites/default/files/files/Teaching/OtherPostGraduateCourses/MasterEstructuras/bibliografia/Deb_NSGAII.pdf
			f = @(x) [(x(:,1)-2).^2 + (x(:,2)-1).^2 + 2,...
							9*x(:,1) - (x(:,2)-1).^2]
			d = 2
			lb = -20
			ub = 20
			nc = 2
			g1 = @(x) 225 - sum(x.^2,2)
			g2 = @(x) 10 - x(:,1) + 3*x(:,2)

		case 'tnk' % http://sci2s.ugr.es/sites/default/files/files/Teaching/OtherPostGraduateCourses/MasterEstructuras/bibliografia/Deb_NSGAII.pdf
			f = @(x) [x(:,1) x(:,2)]	
			d = 2
			lb = 0
			ub = pi
			nc = 2
			g1 = @(x) sum(x.^2,2) - 1 - 0.1*cos(16*atan(x(:,1)./x(:,2)))
			g2 = @(x) 0.5 - sum((x-0.5).^2,2)
			
		case 'water' % http://sci2s.ugr.es/sites/default/files/files/Teaching/OtherPostGraduateCourses/MasterEstructuras/bibliografia/Deb_NSGAII.pdf
			f = @(x) [106780.37*(x(:,2) + x(:,3)) + 61704.67, 3000*x(:,1), (305700)*2289*x(:,2)./((0.06*2289)^0.65), 250*2289*exp(-39.75*x(:,2) + 9.9*x(:,3) + 2.74), 25*((1.39)./(x(:,1).*x(:,2))) + 4940*x(:,3) - 80]	
			d = 3
			lb = [0.01 0.01 0.01]
			ub = [0.45 0.10 0.10]
			nc = 7
			g1 = @(x) 0.00139 ./(x(:,1).*x(:,2)) + 4.94*x(:,3)- 0.08 -1
			g2 = @(x) 0.000306 ./(x(:,1).*x(:,2)) + 1.082*x(:,3) - 0.0986 -1
			g3 = @(x) 12.307 ./(x(:,1).*x(:,2)) + 49408.24*x(:,3) + 4051.02 - 50000
			g4 = @(x) 2.098 ./(x(:,1).*x(:,2)) + 8046.33*x(:,3) - 696.71 - 16000
			g5 = @(x) 2.138 ./(x(:,1).*x(:,2)) + 7883.39*x(:,3) - 705.04 - 10000
			g6 = @(x) 0.417 ./(x(:,1).*x(:,2)) + 1721.26*x(:,3) - 136.54 - 2000
			g7 = @(x) 0.164 ./(x(:,1).*x(:,2)) + 631.13*x(:,3) - 54.48 - 550

		case 'binh&korn' % https://en.wikipedia.org/wiki/Test_functions_for_optimization
			f = @(x) [4*sum(x.^2,2), ...
							sum((x-5).^2,2)]	% cost Function
			d = 2
			lb = [0 0]
			ub = [5 3]
			nc = 2
			g1 = @(x) 25 - (x(:,1)-5).^2 - x(:,2).^2
			g2 = @(x) (x(:,1)-8).^2 + (x(:,2)+3).^2 - 7.7
			
		case 'fonseca&fleming' % https://en.wikipedia.org/wiki/Test_functions_for_optimization
			d = 3
			sqrd = sqrt(d)
			f = @(x) 1 - [	exp(-sum((x-1/sqrd).^2,2)),...
									exp(-sum((x+1/sqrd).^2,2)) ]
			lb = -4*ones(1,d)
			ub = -lb
			
		case 'osyczka&kundu' % https://en.wikipedia.org/wiki/Test_functions_for_optimization			
			f = @(x) [-25*(x(:,1)-2).^2 - (x(:,2)-2).^2 - (x(:,3)-1).^2 - (x(:,4)-4).^2 - (x(:,5)-1).^2, sum(x.^2,2)]	
			d = 6
			lb = [0 0 1 0 1 0]
			ub = [10 10 5 6 5 10]
			nc = 6
			g1 = @(x) x(:,1) + x(:,2) - 2
			g2 = @(x) 6 - x(:,1) - x(:,2)
			g3 = @(x) 2 + x(:,1) - x(:,2)
			g4 = @(x) 2 - x(:,1) + 3*x(:,2)
			g5 = @(x) 4 - (x(:,3) - 3).^2 - x(:,4)
			g6 = @(x) (x(:,5) - 3).^2 + x(:,6) - 4			
		
		case 'schaffer2' % https://en.wikipedia.org/wiki/Test_functions_for_optimization
			f = @(x) [-x.*(x<=1) + (x-2).*(x>1 & x<=3) + (4-x).*(x>3 & x<=4) + (x-4).*(x>4), ...
							(x-5).^2]
			d = 1
			lb = -5
			ub = 10
			
		case 'zdt1' % https://en.wikipedia.org/wiki/Test_functions_for_optimization
			k = @(x) 1 + 9/29*sum(x(:,2:end),2)
			h = @(x,y) 1 - real(sqrt(x./y))
			f = @(x) [x(:,1), k(x).*h(x(:,1),k(x))]
			d = 30
			lb = 0
			ub = 1
			
		case 'zdt2' % https://en.wikipedia.org/wiki/Test_functions_for_optimization
			k = @(x) 1 + 9/29*sum(x(:,2:end),2)
			h = @(x,y) 1 - (x./y).^2
			f = @(x) [x(:,1), k(x).*h(x(:,1),k(x))]
			d = 30
			lb = 0
			ub = 1
			
		case 'zdt4' % https://en.wikipedia.org/wiki/Test_functions_for_optimization
			k = @(x) 91 + sum(x(:,2:end).^2,2) - 10*sum(cos(4*pi*x(:,2:end)),2)
			h = @(x,y) 1 - real(sqrt(x./y))
			f = @(x) [x(:,1), k(x).*h(x(:,1),k(x))]
			d = 10
			lb = [0 -5*ones(1,9)]
			ub = [1 5*ones(1,9)]
			
		otherwise
			error(['function ' id ' not found in mathlayer® optimization benchmarks suite'])

	end
	
	% setting constraints
	switch nc
	case 1
		g = @(x) g1(x).*(g1(x)<0)
	case 2
		g = @(x) g1(x).*(g1(x)<0) + g2(x).*(g2(x)<0)
	case 3
		g = @(x) g1(x).*(g1(x)<0) + g2(x).*(g2(x)<0) + g3(x).*(g3(x)<0)
	case 4
		g = @(x) g1(x).*(g1(x)<0) + g2(x).*(g2(x)<0) + g3(x).*(g3(x)<0) + g4(x).*(g4(x)<0)
	case 5
		g = @(x) g1(x).*(g1(x)<0) + g2(x).*(g2(x)<0) + g3(x).*(g3(x)<0) + g4(x).*(g4(x)<0) + g5(x).*(g5(x)<0)
	case 6
		g = @(x) g1(x).*(g1(x)<0) + g2(x).*(g2(x)<0) + g3(x).*(g3(x)<0) + g4(x).*(g4(x)<0) + g5(x).*(g5(x)<0) + g6(x).*(g6(x)<0)
	case 7
		g = @(x) g1(x).*(g1(x)<0) + g2(x).*(g2(x)<0) + g3(x).*(g3(x)<0) + g4(x).*(g4(x)<0) + g5(x).*(g5(x)<0) + g6(x).*(g6(x)<0) + g7(x).*(g7(x)<0)
	end
	
	o.d = d
	o.lb = lb
	o.ub = ub
	if nc>0, o.g = g; end
	
end