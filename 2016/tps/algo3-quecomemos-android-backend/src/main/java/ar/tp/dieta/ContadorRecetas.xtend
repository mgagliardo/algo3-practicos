package ar.tp.dieta

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class ContadorRecetas {

	Receta receta
	int cantidad
	
	new(Receta unaReceta, int unaCantidad){
		cantidad = unaCantidad
		receta = unaReceta
	}
	
}