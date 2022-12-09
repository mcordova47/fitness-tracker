import { useEffect } from "react"

export const _browserEvents = props => {
  useEffect(() => {
    window.addEventListener('mouseup', props.mouseup)
    return () => {
      window.removeEventListener('mouseup', props.mouseup)
    }
  })
  return null
}
