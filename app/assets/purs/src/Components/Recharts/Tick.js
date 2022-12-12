import React from 'react'

export const tick_ = props => React.createElement(
  'g',
  {
    transform: `translate(${props.x},${props.y})`
  },
  React.createElement(
    'text',
    {
      className: 'dark:fill-white',
      textAnchor: props.textAnchor,
      x: 0,
      y: 0,
      dy: 16
    },
    props.tickFormatter ? props.tickFormatter(props.payload.value) : props.payload.value
  )
)
