export interface ViewConstructor {
  new() : View
}
export interface View {
  mount(): void
  unmount(): void
}
