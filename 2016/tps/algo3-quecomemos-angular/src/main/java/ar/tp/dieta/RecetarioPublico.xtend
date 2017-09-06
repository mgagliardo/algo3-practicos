package ar.tp.dieta

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class RecetarioPublico implements Cloneable{
	List<Receta> recetas = new ArrayList<Receta>()
	
	def void agregarReceta(Receta unaReceta) {
		//agrega recetas al recetario
		recetas.add(unaReceta)
	}

	def void mirarRecetario() {
		//imprime los nombres de las recetas
		recetas.forEach[receta|println(receta.getNombreDeLaReceta)]
	}

	def elegirReceta(String nombre) {
		if(this.busquedaReceta(nombre)==null){
			throw new BusinessException("La receta buscada no existe.")
		}
		this.busquedaReceta(nombre)
		// devuelve la primer receta que conincide con el nombre pasado
		
	}
	
	def busquedaReceta(String nombreReceta){
		recetas.findFirst[receta|receta.getNombreDeLaReceta.equals(nombreReceta)]
	}
	
/*copiarReceta inicializa una nueva variable recetaTemporal, a 
 * la que se le va a asignar la coincidencia de buscar la receta
 * requerida en el listado de recetas (metodo busquedaReceta)
 * luego se copiaran todos los atributos 1x1 de una receta a otra y
 *  se retornara la nueva Receta con todos los atributos copiados*/
	
	def Receta copiarReceta(String nombreReceta, String nuevoNombreReceta){
		val Receta recetaTemporal = this.busquedaReceta(nombreReceta)
		var Receta unaReceta = new Receta

		if(!(recetaTemporal.nombreDeLaReceta.equals(nuevoNombreReceta))){ //Si el nombre deseado no coincide con el de la receta a copiar lo reescribo
			unaReceta.setNombreDeLaReceta(nuevoNombreReceta)
		}
		else{
			unaReceta.setNombreDeLaReceta(recetaTemporal.getNombreDeLaReceta())
		}

		unaReceta.setCalorias(recetaTemporal.getCalorias())
		unaReceta.setProcesoDePreparacion(recetaTemporal.getProcesoDePreparacion())
		unaReceta.setDificultadDePreparacion(recetaTemporal.getDificultadDePreparacion())
		unaReceta.setTemporadaALaQueCorresponde(recetaTemporal.getTemporadaALaQueCorresponde())
		unaReceta.ingredientes = new ArrayList<Ingrediente>(recetaTemporal.ingredientes)
		unaReceta.condimentos = new ArrayList<Condimento>(recetaTemporal.condimentos)
		
		unaReceta
	}
	
}