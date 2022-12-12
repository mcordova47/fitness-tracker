import React from 'react'
import Select from 'react-select'

export const select_ = props => React.createElement(
  Select,
  {
    ...props,
    classNames: {
      control: () => 'dark:bg-slate-700 dark:border-slate-600 shadow-none focus-within:border-cyan-600',
      input: () => 'dark:text-white',
      menu: () => 'dark:bg-slate-700',
      option: args => args.isFocused ? 'bg-cyan-50 dark:bg-slate-600' : '',
      placeholder: () => 'dark:text-white'
    }
  }
)
