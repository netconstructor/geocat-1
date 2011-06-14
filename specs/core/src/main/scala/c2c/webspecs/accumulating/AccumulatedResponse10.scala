package c2c.webspecs
package accumulating

import AccumulatingRequest._
import ChainedRequest.ConstantRequestFunction


case class AccumulatedResponse10[+T1,+T2,+T3,+T4,+T5,+T6,+T7,+T8,+T9,+T10,+Z](
    val _1:Response[T1],
    val _2:Response[T2],
    val _3:Response[T3],
    val _4:Response[T4],
    val _5:Response[T5],
    val _6:Response[T6],
    val _7:Response[T7],
    val _8:Response[T8],
    val _9:Response[T9],
    val _10:Response[T10],
    val last:Response[Z])
  extends AccumulatedResponse[Z] {

  def tuple = (
    _1,
    _2,
    _3,
    _4,
    _5,
    _6,
    _7,
    _8,
    _9,
    _10,
    last
  )

  def values = (
    _1.value,
    _2.value,
    _3.value,
    _4.value,
    _5.value,
    _6.value,
    _7.value,
    _8.value,
    _9.value,
    _10.value,
    last.value
  )
}