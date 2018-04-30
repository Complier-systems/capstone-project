var1 = 3;
var4 = 15;
if(var1 == 3){
	var1 = var1 - ++--++-+2;
	if(var4 == 15){
		loop(var1,var4){
			print(5);
			var1 = var1 + 1;
		}
		println(" ");
		var2 = 0;
		loop(var1,var4){
			if(var2 == var1){
				println("Reach var1");
			}
			var2 = var2 + 1;
		}		
	}
}
else{
	print(var1);
}

print("Finish!!");
